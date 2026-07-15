{
  lib,
  config,
  secrets,
  ...
}: let
  inherit (builtins) toString;
  inherit (lib) mkOption types;

  inherit (config.apollo.services.authelia) middleware;
  inherit (config.apollo.services.traefik) dashboardPrefix;
  inherit (config.services.tailscale-traefik) fqdn;

  instance = "main";
  user = "authelia-${instance}";
  group = user;
  uid = 42421;
  gid = 42421;

  port = 9091;

  prefix = "/authelia";

  stateDir = "/var/lib/authelia-${instance}/";

  mkSecret = file: {
    file = "${secrets}/${file}";
    owner = user;
    group = group;
    mode = "0400";
  };

  jwtSecret = "authelia-jwt-secret";
  sessionSecret = "authelia-session-secret";
  storageEncryptionKey = "authelia-storage-encryption-key";
  oidcHmacSecret = "authelia-oidc-hmac-secret";
  oidcIssuerPrivateKey = "authelia-oidc-issuer-private-key";

  traefikService = "authelia-${instance}";
in {
  options.apollo.services.authelia = {
    prefix = mkOption {
      type = types.str;
      default = prefix;
      readOnly = true;
    };

    middleware = mkOption {
      type = types.str;
      default = "authelia-${instance}";
      readOnly = true;
    };
    singleton = mkOption {
      type = types.str;
      default = instance;
      readOnly = true;
    };
  };

  config = {
    users = {
      users.${user} = {
        inherit group uid;
        isSystemUser = true;
      };
      groups.${group} = {inherit gid;};
    };

    age.secrets = {
      ${jwtSecret} = mkSecret "apollo-authelia-jwt-secret.age";
      ${sessionSecret} = mkSecret "apollo-authelia-session-secret.age";
      ${storageEncryptionKey} = mkSecret "apollo-authelia-storage-encryption-key.age";
      ${oidcHmacSecret} = mkSecret "apollo-grafana-authelia-oidc-hmac-secret.age";
      ${oidcIssuerPrivateKey} = mkSecret "apollo-authelia-oidc-issuer-private-key.age";
    };

    services = {
      traefik = {
        dynamicConfigOptions = {
          http = {
            middlewares.${middleware}.forwardAuth = {
              address = "http://127.0.0.1:${toString port}/api/authz/forward-auth";
              trustForwardHeader = true;
              maxResponseBodySize = 8192;
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Email"
                "Remote-Name"
              ];
            };

            services.${traefikService}.loadBalancer.servers = [
              {
                url = "http://127.0.0.1:${toString port}/";
              }
            ];

            routers = {
              ${traefikService} = {
                rule = "Host(`${fqdn}`) && PathPrefix(`${prefix}`)";
                service = traefikService;
              };
            };
          };
        };
      };

      authelia.instances.${instance} = {
        enable = true;
        inherit user group;
        secrets = {
          jwtSecretFile = config.age.secrets.${jwtSecret}.path;
          sessionSecretFile = config.age.secrets.${sessionSecret}.path;
          storageEncryptionKeyFile = config.age.secrets.${storageEncryptionKey}.path;
          oidcHmacSecretFile = config.age.secrets.${oidcHmacSecret}.path;
          oidcIssuerPrivateKeyFile = config.age.secrets.${oidcIssuerPrivateKey}.path;
        };

        settings = {
          default_2fa_method = "webauthn";

          server = {
            address = "tcp://127.0.0.1:${toString port}${prefix}";
            endpoints.authz."forward-auth".implementation = "ForwardAuth";
          };

          authentication_backend.file = {
            path = "${stateDir}/users.yaml";
            watch = true;
            search.email = true;
          };

          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = fqdn;
                policy = "two_factor";
              }
            ];
          };

          session = {
            name = "authelia_apollo_session";
            cookies = [
              {
                domain = fqdn;
                authelia_url = "https://${fqdn}${prefix}";
                default_redirection_url = "https://${fqdn}${dashboardPrefix}/";
              }
            ];
          };

          storage.local.path = "${stateDir}/db.sqlite3";

          notifier = {
            # filesystem.filename = "${stateDir}/notification";
            smtp = {
              address = "smtp://127.0.0.1:${toString config.apollo.services.postfix.port}";
              sender = "Authelia on Apollo <authelia@Apollo>";
              identifier = "fqdn";
              disable_starttls = true;
              disable_require_tls = true;
            };
          };

          webauthn = {
            enable_passkey_login = true;
            experimental_enable_passkey_uv_two_factors = true;
            display_name = config.networking.hostName;
          };
        };
      };
    };

    environment.persistence.${config.apollo.mountpoints.persist}.directories = [
      {
        directory = stateDir;
        inherit user group;
        mode = "u=rwx,g=,o=";
      }
    ];
  };
}

{
  environment.etc."authelia/storageEncryptionKeyFile" = {
    mode = "0400";
    user = "authelia-testing";
    text = "you_must_generate_a_random_string_of_more_than_twenty_chars_and_configure_this";
  };
  environment.etc."authelia/jwtSecretFile" = {
    mode = "0400";
    user = "authelia-testing";
    text = "a_very_important_secret";
  };
  environment.etc."authelia/users_database.yml" = {
    mode = "0400";
    user = "authelia-testing";
    text = ''
      users:
        bob:
          disabled: false
          displayname: bob
          # password of password
          password: $argon2id$v=19$m=65536,t=3,p=4$2ohUAfh9yetl+utr4tLcCQ$AsXx0VlwjvNnCsa70u4HKZvFkC8Gwajr2pHGKcND/xs
          email: bob@jim.com
          groups:
            - admin
            - dev
    '';
  };

  systemd.services.authelia-testing.serviceConfig.Environment = "X_AUTHELIA_CONFIG_FILTERS=template";

  services = {
    tailscale-traefik.enable = true;

    authelia.instances.testing = {
      enable = true;
      secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
      secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
      settings = {
        server.address = "tcp://127.0.0.1:9091/auth";
        authentication_backend.file.path = "/etc/authelia/users_database.yml";
        access_control.default_policy = "one_factor";
        session = {
          cookies = [
            {
              domain = "apollo.snow-dace.ts.net";
              authelia_url = "https://apollo.snow-dace.ts.net/auth";
            }
          ];
          name = "apollo-authelia";
        };
        storage.local.path = "/tmp/db.sqlite3";
        notifier.filesystem.filename = "/tmp/notifications.txt";
      };
    };

    traefik = {
      staticConfigOptions = {
        log.level = "DEBUG";
        accessLog = {};
        api = {};
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            dashboard = {
              rule = "PathPrefix(`/api`) || PathPrefix(`/dashboard`)";
              service = "api@internal";
              middlewares = ["authelia@file"];
            };
            authelia = {
              rule = "PathPrefix(`/auth`)";
              service = "authelia";
              entrypoints = ["secure"];
            };
          };
          services = {
            authelia = {
              loadBalancer.servers = [{url = "http://localhost:9091";}];
            };
          };
          middlewares = {
            authelia.forwardAuth = {
              address = "http://localhost:9091/api/authz/forward-auth";
              trustForwardHeader = true;
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Email"
                "Remote-Name"
              ];
            };
            authelia-basic.forwardAuth = {
              address = "http://localhost:9091/api/verify?auth=basic";
              trustForwardHeader = true;
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Email"
                "Remote-Name"
              ];
            };
          };
        };
      };
    };
  };
}

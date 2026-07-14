{
  config,
  secrets,
  ...
}: let
  inherit (config.services.tailscale-traefik) fqdn;

  prefix = "/grafana";

  traefikService = "grafana";

  port = 3000;

  mkSecret = file: {
    file = "${secrets}/${file}";
    owner = "grafana";
    group = "grafana";
  };

  secretKey = "grafana-secret-key";
  oidcClientSecret = "grafana-oidc-client-secret";

  clientId = "8c4FlbukPf-ws4mcfFzHIP8Oc16.mcToG5lBPYhA0a9NbA8I4A~Lgin.KWuqyF3iuAEz_7VR";

  authApiBaseUrl = "https://${fqdn}${config.apollo.services.authelia.prefix}/api";

  baseUrl = "https://${fqdn}${prefix}";
in {
  age.secrets = {
    ${secretKey} = mkSecret "apollo-grafana-secret-key.age";
    ${oidcClientSecret} = mkSecret "apollo-grafana-oidc-secret-key.age";
  };

  services = {
    grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = port;
          enforce_domain = true;
          enable_gzip = true;

          domain = fqdn;
          root_url = baseUrl;
          serve_from_sub_path = true;
        };
        security.secret_key = "$__file{${config.age.secrets.${secretKey}.path}}";
        "auth.generic_oauth" = {
          enabled = true;
          name = "Authelia";
          client_id = clientId;
          client_secret = "$__file{${config.age.secrets.${oidcClientSecret}.path}}";
          scopes = ["openid" "profile" "email" "groups"];
          empty_scopes = false;
          auth_url = "${authApiBaseUrl}/oidc/authorization";
          token_url = "${authApiBaseUrl}/oidc/token";
          api_url = "${authApiBaseUrl}/oidc/userinfo";
          login_attribute_path = "preferred_username";
          groups_attribute_path = "groups";
          name_attribute_path = "name";
          role_attribute_path = "contains(groups, 'grafana_admins') && 'Admin' || 'Viewer'";
          use_pkce = true;
          auth_style = "InHeader";
          auto_login = true;
        };
        "auth.basic".enabled = false;
      };
    };

    traefik = {
      dynamicConfigOptions.http = {
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

    authelia.instances.${config.apollo.services.authelia.singleton} = {
      settings.identity_providers.oidc = {
        claims_policies.grafana.id_token = [
          "email"
          "name"
          "groups"
          "preferred_username"
        ];

        clients = [
          {
            client_name = "Grafana";
            client_id = clientId;
            client_secret = "$pbkdf2-sha512$310000$hUh4yWfaCYOJbSMUCbKAHQ$wjSf3cpoqvecE0ADD.ybh6Cwj8.wCu5l2/8ORkyWN.sJOdEafuzEr856sEphrjaMYvKE7tJOIVwHmCHhaYrKvQ";
            claims_policy = "grafana";
            redirect_uris = ["${baseUrl}/login/generic_oauth"];
            scopes = [
              "openid"
              "profile"
              "groups"
              "email"
            ];
            response_types = ["code"];
            grant_types = ["authorization_code"];
            require_pkce = true;
            pkce_challenge_method = "S256";
            access_token_signed_response_alg = "none";
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_basic";
          }
        ];
      };
    };
  };
}

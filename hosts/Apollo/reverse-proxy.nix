{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;

  inherit (config.apollo.services.traefik) dashboardPrefix;

  authMiddleware = config.apollo.services.authelia.middleware;
in {
  options.apollo.services.traefik.dashboardPrefix = mkOption {
    type = types.str;
    default = "/dashboard";
    readOnly = true;
  };

  config.services = {
    tailscale-traefik.enable = true;

    traefik = {
      staticConfigOptions = {
        log.level = "DEBUG";
        api = {};
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            dashboard = {
              rule = "PathPrefix(`/api`) || PathPrefix(`${dashboardPrefix}`)";
              middlewares = [authMiddleware];
              service = "api@internal";
            };
          };
        };
      };
    };
  };
}

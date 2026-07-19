{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;

  inherit (config.apollo.services.traefik) dashboardPrefix metricsPort;

  authMiddleware = config.apollo.services.authelia.middleware;
in {
  options.apollo.services.traefik = {
    dashboardPrefix = mkOption {
      type = types.str;
      default = "/dashboard";
      readOnly = true;
    };

    metricsPort = mkOption {
      type = types.port;
      default = 8082;
      readOnly = true;
    };
  };

  config.services = {
    tailscale-traefik.enable = true;

    traefik = {
      staticConfigOptions = {
        # log.level = "DEBUG";
        accesslog.bufferingSize = 256;
        api = {};

        entryPoints.metrics.address = "127.0.0.1:${toString metricsPort}";
        metrics.prometheus.entryPoint = "metrics";
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

    prometheus.scrapeConfigs = [
      {
        job_name = "${config.networking.hostName}-traefik";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString metricsPort}"];
            labels.instance = config.networking.hostName;
          }
        ];
      }
    ];
  };
}

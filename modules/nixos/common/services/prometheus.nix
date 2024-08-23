{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
in {
  options.dotfiles.nixoss.props.services.prometheusReportToDemeter = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf config.dotfiles.nixoss.props.services.prometheusReportToDemeter {
    services.prometheus = {
      enable = true;
      enableReload = true;
      enableAgentMode = true;

      listenAddress = "127.0.0.1";

      scrapeConfigs = [
        {
          job_name = "${config.networking.hostName}-node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
      ];

      remoteWrite = [
        {
          name = "demeter";
          url = "https://demeter.snow-dace.ts.net/prometheus/write";
        }
      ];

      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          listenAddress = "127.0.0.1";
        };
      };
    };
  };
}

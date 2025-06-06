{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
in {
  options.dotfiles.nixos.props.services.prometheus = {
    pushToCollector = mkOption {
      type = types.bool;
      default = true;
    };
    collectorUrl = mkOption {
      type = types.str;
      default = "https://persephone.snow-dace.ts.net/prometheus/write";
    };
  };

  config = mkIf config.dotfiles.nixos.props.services.prometheus.pushToCollector {
    systemd.services.prometheus.bindsTo = ["tailscaled.service"];

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
        {
          job_name = "${config.networking.hostName}-smartctl";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
        {
          job_name = "${config.networking.hostName}-systemd";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
      ];

      remoteWrite = [
        {
          name = "ts-remote-collector";
          url = config.dotfiles.nixos.props.services.prometheus.collectorUrl;
        }
      ];

      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
        };
        smartctl.enable = true;
        systemd.enable = true;
      };
    };
  };
}

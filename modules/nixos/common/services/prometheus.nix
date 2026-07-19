{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    types
    mkMerge
    ;
in {
  options.dotfiles.nixos.props.services.prometheus = {
    enableDefault = mkOption {
      type = types.bool;
      default = config.dotfiles.nixos.props.services.prometheus.pushToCollector;
    };

    pushToCollector = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion =
            config.dotfiles.nixos.props.services.prometheus.pushToCollector
            -> config.dotfiles.shared.props.location.prometheus != null;
          message = "master prometheus node url is not defined for this location";
        }
      ];
    }
    (mkIf config.dotfiles.nixos.props.services.prometheus.enableDefault {
      services.prometheus = {
        enable = true;
        enableReload = true;

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

        exporters = {
          node = {
            enable = true;
            enabledCollectors = ["systemd"];
          };
          smartctl.enable = true;
          systemd.enable = true;
        };
      };
    })
    (mkIf config.dotfiles.nixos.props.services.prometheus.pushToCollector {
      systemd.services.prometheus.bindsTo = ["tailscaled.service"];
      services.prometheus = {
        enableAgentMode = true;

        remoteWrite = [
          {
            name = "ts-remote-collector";
            url = config.dotfiles.shared.props.location.prometheus;
          }
        ];
      };
    })
  ];
}

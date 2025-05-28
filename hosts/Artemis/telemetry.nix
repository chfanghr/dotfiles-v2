{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkForce attrValues mapAttrsToList genAttrs;
  cfg = config.artemis.telemetry;
  artemisHostname = config.networking.hostName;
  exporterPorts = genAttrs cfg.enabledExporters (name: config.services.prometheus.exporters.${name}.port);
  tailscalePackage = config.services.tailscale.package;
in {
  options.artemis.telemetry = {
    containerName = mkOption {type = types.str;};

    lan = {
      veth = mkOption {type = types.str;};
      hostBridge = mkOption {type = types.str;};
    };

    monitoring = {
      veth = mkOption {type = types.str;};
      hostAddress = mkOption {type = types.str;};
      localAddress = mkOption {type = types.str;};
    };

    enabledExporters = mkOption {type = types.listOf types.str;};
  };

  config = {
    artemis.telemetry = {
      containerName = "artemis-telemetry";
      lan = {
        veth = "ve-spy-lan";
        hostBridge = config.artemis.networking.lanBridge.interface;
      };
      monitoring = {
        veth = "ve-spy-mon";
        hostAddress = "172.16.0.1";
        localAddress = "172.16.0.2";
      };
      enabledExporters = ["node" "systemd" "smartctl" "zfs"];
    };

    networking.firewall.interfaces.${cfg.monitoring.veth}.allowedTCPPorts =
      attrValues exporterPorts;

    containers.${cfg.containerName} = {
      autoStart = true;

      privateNetwork = true;
      enableTun = true;

      extraVeths = {
        ${cfg.lan.veth} = {inherit (cfg.lan) hostBridge;};
        ${cfg.monitoring.veth} = {inherit (cfg.monitoring) hostAddress localAddress;};
      };

      config = {
        imports = [../../modules/nixos/common/services/prometheus.nix];

        networking = {
          enableIPv6 = true;
          useNetworkd = true;
          useDHCP = false;
          useHostResolvConf = mkForce false;
          firewall.enable = true;
          nftables.enable = true;
        };

        services = {
          resolved.enable = true;
          tailscale = {
            enable = true;
            package = tailscalePackage;
            useRoutingFeatures = lib.mkForce "both";
            extraSetFlags = ["--advertise-routes" "10.31.0.0/16"];
          };

          prometheus.scrapeConfigs =
            mapAttrsToList (name: port: {
              job_name = "${artemisHostname}-${name}";
              static_configs = [
                {
                  targets = [
                    "${cfg.monitoring.hostAddress}:${toString port}"
                  ];
                  labels.instance = artemisHostname;
                }
              ];
            })
            exporterPorts;
        };

        systemd.network = {
          wait-online.ignoredInterfaces = [cfg.lan.veth];
          networks = {
            "40-${cfg.lan.veth}" = {
              matchConfig.Name = cfg.lan.veth;
              networkConfig = {
                DHCP = true;
                IPv6AcceptRA = true;
                IPv6PrivacyExtensions = "kernel";
              };
            };
            "40-${cfg.monitoring.veth}" = {
              matchConfig.Name = cfg.monitoring.veth;
              linkConfig.Unmanaged = true;
            };
          };
        };

        system.stateVersion = "24.11";
      };
    };

    systemd.network.networks."40-${cfg.monitoring.veth}" = {
      matchConfig.Name = cfg.monitoring.veth;
      linkConfig.Unmanaged = true;
    };
  };
}

{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types concatStringsSep mkEnableOption mkForce;
in {
  options.hestia.networking = {
    server = {
      enable = mkEnableOption "server mode networking setup";

      lanBridge = {
        interface = mkOption {type = types.str;};
        netdevProfile = mkOption {type = types.str;};
        networkProfile = mkOption {type = types.str;};

        slave = {
          interfaces = mkOption {type = types.nonEmptyListOf types.str;};
          networkProfile = mkOption {type = types.str;};
        };

        dummy = {
          interface = mkOption {type = types.str;};
          netdevProfile = mkOption {type = types.str;};
          networkProfile = mkOption {type = types.str;};
        };
      };
      ap = {
        device = mkOption {type = types.str;};

        ssid = mkOption {type = types.str;};

        encryptedPasswordFile = mkOption {type = types.pathInStore;};
      };
    };
    desktop = {
      enable = mkEnableOption "desktop mode networking setup";

      lanBridge = {
        interface = mkOption {type = types.str;};

        slave.interfaces = mkOption {type = types.nonEmptyListOf types.str;};
      };
    };
  };

  imports = [
    {
      networking = {
        firewall.enable = true;
        nftables.enable = true;

        interfaces = {
          enp198s0f3u1 = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = "192.168.255.5";
                prefixLength = 24;
              }
            ];
          };
        };

        useDHCP = false;
      };

      services = {
        iperf3 = {
          enable = true;
          openFirewall = true;
        };
        lldpd.enable = true;
      };

      hestia.networking = {
        server = {
          lanBridge = {
            interface = "br0";
            netdevProfile = "40-br0";
            networkProfile = "40-br0";
            slave = {
              interfaces = ["enp195s0"];
              networkProfile = "40-br0-slaves";
            };
            dummy = {
              interface = "dummy0";
              netdevProfile = "40-dummy0";
              networkProfile = "40-dummy0";
            };
          };
          ap = {
            device = "wlp194s0";
            ssid = "Hestia";
            encryptedPasswordFile = ../../secrets/hestia-ap-password.age;
          };
        };
        desktop = {
          lanBridge = {
            interface = "br0";
            slave.interfaces = ["enp195s0"];
          };
        };
      };
    }

    (
      let
        cfg = config.hestia.networking.desktop;
      in
        mkIf cfg.enable {
          networking = {
            useNetworkd = false;
            networkmanager.enable = true;

            bridges.${cfg.lanBridge.interface}.interfaces =
              cfg.lanBridge.slave.interfaces;

            interfaces.${cfg.lanBridge.interface}.useDHCP = true;
          };
        }
    )
    (
      let
        cfg = config.hestia.networking.server;
      in
        mkIf cfg.enable {
          networking.useNetworkd = true;

          systemd.network = {
            netdevs = {
              ${cfg.lanBridge.netdevProfile} = {
                netdevConfig = {
                  Kind = "bridge";
                  Name = cfg.lanBridge.interface;
                };
              };
              ${cfg.lanBridge.dummy.netdevProfile}.netdevConfig = {
                Kind = "dummy";
                Name = cfg.lanBridge.dummy.interface;
              };
            };

            networks = {
              ${cfg.lanBridge.networkProfile} = {
                matchConfig.Name = cfg.lanBridge.interface;
                networkConfig = {
                  DHCP = "ipv4";
                  IPv4Forwarding = "yes";
                  IPv6Forwarding = "yes";
                  IPv6AcceptRA = true;
                  IPv6PrivacyExtensions = "kernel";
                };
                bridgeConfig.UseBPDU = true;
              };
              ${cfg.lanBridge.slave.networkProfile} = {
                matchConfig.Name = concatStringsSep " " cfg.lanBridge.slave.interfaces;
                networkConfig.Bridge = cfg.lanBridge.interface;
                linkConfig.RequiredForOnline = "enslaved";
              };
              ${cfg.lanBridge.dummy.networkProfile} = {
                matchConfig.Name = cfg.lanBridge.dummy.interface;
                networkConfig.Bridge = cfg.lanBridge.interface;
              };
              "40-dont-touch-veth" = {
                matchConfig = {
                  Name = "ve-*";
                  Kind = "veth";
                };
                linkConfig.Unmanaged = true;
              };
            };
          };

          age.secrets.ap-password.file = cfg.ap.encryptedPasswordFile;

          services.hostapd = {
            enable = true;

            radios.${cfg.ap.device} = {
              band = "5g";
              channel = 149;
              countryCode = "CN";

              wifi4.enable = true;
              wifi5.enable = true;
              wifi6 = {
                enable = true;
                multiUserBeamformer = true;
                singleUserBeamformer = true;
              };
              wifi7 = {
                enable = true;
                multiUserBeamformer = true;
                singleUserBeamformer = true;
              };

              networks.${cfg.ap.device} = {
                ssid = cfg.ap.ssid;
                logLevel = 0;
                authentication = {
                  enableRecommendedPairwiseCiphers = true;
                  pairwiseCiphers = [
                    "CCMP-256"
                    "GCMP-256"
                  ];
                  saePasswordsFile = config.age.secrets.ap-password.path;
                };
                settings.bridge = cfg.lanBridge.interface;
              };
            };
          };

          services.tailscale.useRoutingFeatures = mkForce "both";

          systemd.services.hostapd.bindsTo = [
            "sys-devices-virtual-net-${cfg.lanBridge.interface}.device"
          ];
        }
    )
  ];
}

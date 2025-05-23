{
  config,
  lib,
  ...
}: let
  cfg = config.artemis.networking;
  inherit (lib) types mkOption mkForce concatStringsSep;
in {
  options.artemis.networking = {
    mgmt = {
      interface = mkOption {type = types.str;};
      networkProfile = mkOption {type = types.str;};
    };

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
  };

  config = {
    networking = {
      useDHCP = mkForce false;
      enableIPv6 = true;
      useNetworkd = true;
      nftables.enable = true;

      firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = with config.services.prometheus.exporters; [
        node.port
        systemd.port
        smartctl.port
      ];
    };

    artemis.networking = {
      mgmt = {
        interface = "enp2s0";
        networkProfile = "40-enp2s0";
      };

      lanBridge = {
        interface = "br0";
        netdevProfile = "40-br0";
        networkProfile = "40-br0";
        slave = {
          interfaces = [
            "enp3s0"
            "enp4s0"
            "enp5s0"
          ];
          networkProfile = "40-br0-slaves";
        };
        dummy = {
          interface = "dummy0";
          netdevProfile = "40-dummy0";
          networkProfile = "40-dummy0";
        };
      };
    };

    systemd.network = {
      netdevs = {
        ${cfg.lanBridge.netdevProfile} = {
          netdevConfig = {
            Kind = "bridge";
            Name = cfg.lanBridge.interface;
          };
          bridgeConfig.STP = true;
        };
        ${cfg.lanBridge.dummy.netdevProfile}.netdevConfig = {
          Kind = "dummy";
          Name = cfg.lanBridge.dummy.interface;
        };
      };

      networks = {
        ${cfg.mgmt.networkProfile} = {
          matchConfig.Name = cfg.mgmt.interface;
          networkConfig = {
            DHCP = "ipv4";
            LLDP = true;
            EmitLLDP = "yes";
            IPv6AcceptRA = "yes";
          };
        };
        ${cfg.lanBridge.networkProfile} = {
          matchConfig.Name = cfg.lanBridge.interface;
          networkConfig = {
            DHCP = false;
            LLDP = true;
            EmitLLDP = "yes";
            IPv4Forwarding = "yes";
            IPv6Forwarding = "yes";
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
      };
    };

    containers.sim-lan-host = {
      autoStart = true;

      ephemeral = true;

      privateNetwork = true;
      hostBridge = cfg.lanBridge.interface;

      config = {
        lib,
        pkgs,
        ...
      }: {
        networking = {
          useNetworkd = true;

          nftables.enable = true;
          firewall.enable = true;

          useHostResolvConf = lib.mkForce false;

          enableIPv6 = true;

          nameservers = [
            "1.1.1.1"
            "233.5.5.5"
            "114.114.114.114"
          ];
        };

        services.resolved.enable = true;

        systemd.network = {
          wait-online.enable = false;
          config.dhcpV4Config = {
            DUIDType = "vendor";
            DUIDRawData = "00:00:ab:11:30:a8:a9:28:56:de:e9:8e";
          };
          networks."40-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "ipv4";
              IPv6AcceptRA = true;
            };
            dhcpV4Config.IAID = lib.fromHexString "0x313149f";
          };
        };

        environment.systemPackages = with pkgs; [
          dig
          curl
          trippy
          ethtool
          speedtest-cli
          fast-cli
        ];

        time.timeZone = "Asia/Hong_Kong";
        system.stateVersion = "24.11";
      };
    };
  };
}

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
  };
}

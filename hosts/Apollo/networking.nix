{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;

  mkProfile = name: "10-${name}";
  mkVlanProfile = name: mkProfile "vlan-${name}";

  cfg = config.apollo.networking.interfaces;
in {
  options.apollo.networking.interfaces = mkOption {
    type = types.attrs;
    default = {
      mainVlan = rec {
        name = "main";
        vlanId = 42;
        profile = mkVlanProfile name;
      };
      mgmtVlan = rec {
        name = "mgmt";
        vlanId = 120;
        profile = mkVlanProfile name;
      };
      phy = rec {
        iface = "enp6s0f0np0";
        profile = mkProfile iface;
      };

      containerPhy = rec {
        iface = "enp6s0f1np1";
        profile = mkProfile iface;
      };
      containerBridge = rec {
        name = "br-container";
        profile = mkProfile name;
      };

      aux = rec {
        name = "aux";
        ifaces = [
          "enp14s0"
          "enp15s0"
          "enp16s0"
        ];
        profile = mkProfile name;
      };
    };
    readOnly = true;
  };

  config = {
    hardware.facter.detected.dhcp.enable = false;

    networking = {
      useNetworkd = true;
      firewall.enable = true;
      nftables.enable = true;
      useDHCP = false;
      enableIPv6 = true;
    };

    systemd.network = {
      netdevs = {
        # Host Vlans
        ${cfg.mainVlan.profile} = {
          netdevConfig = {
            Kind = "vlan";
            Name = cfg.mainVlan.name;
          };
          vlanConfig = {
            Id = cfg.mainVlan.vlanId;
          };
        };
        ${cfg.mgmtVlan.profile} = {
          netdevConfig = {
            Kind = "vlan";
            Name = cfg.mgmtVlan.name;
          };
          vlanConfig = {
            Id = cfg.mgmtVlan.vlanId;
          };
        };
        # Container
        ${cfg.containerBridge.profile} = {
          netdevConfig = {
            Kind = "bridge";
            Name = cfg.containerBridge.name;
          };
          bridgeConfig = {
            DefaultPVID = cfg.mainVlan.vlanId;
            STP = true;
            VLANFiltering = true;
          };
        };
      };
      networks = {
        # Host Interfaces
        ${cfg.phy.profile} = {
          matchConfig.Name = cfg.phy.iface;
          networkConfig = {
            LLDP = true;
            EmitLLDP = true;
            IPv6AcceptRA = false;
            LinkLocalAddressing = false;
            VLAN = [
              cfg.mainVlan.name
              cfg.mgmtVlan.name
            ];
          };
        };
        ${cfg.mainVlan.profile} = {
          matchConfig.Name = cfg.mainVlan.name;
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
            IPv6PrivacyExtensions = "kernel";
          };
        };
        ${cfg.mgmtVlan.profile} = {
          matchConfig.Name = cfg.mgmtVlan.name;
          networkConfig = {
            LLDP = true;
            EmitLLDP = true;
            Address = "10.5.0.11/16";
            IPv6PrivacyExtensions = "kernel";
          };
        };
        # Container network
        "${cfg.containerPhy.profile}" = {
          matchConfig.Name = cfg.containerPhy.iface;
          linkConfig.RequiredForOnline = "enslaved";
          networkConfig.Bridge = cfg.containerBridge.name;
          bridgeVLANs = [{PVID = cfg.mainVlan.vlanId;}];
        };
        "${cfg.containerBridge.profile}" = {
          matchConfig.Name = cfg.containerBridge.name;
          networkConfig = {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
            LinkLocalAddressing = false;
          };
          bridgeConfig.UseBPDU = true;
          bridgeVLANs = [
            {
              PVID = cfg.mainVlan.vlanId;
              VLAN = cfg.mainVlan.vlanId;
            }
          ];
        };
        # Aux
        "${cfg.aux.profile}" = {
          matchConfig.Name = cfg.aux.ifaces;
          linkConfig.RequiredForOnline = "no";
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
            IPv6PrivacyExtensions = "kernel";
          };
        };
      };
    };

    containers.sim-lan-host = {
      autoStart = true;

      ephemeral = true;

      privateNetwork = true;
      hostBridge = cfg.containerBridge.name;

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
        };

        services.resolved.enable = true;

        systemd.network = {
          wait-online.enable = false;
          config.dhcpV4Config = {
            DUIDType = "vendor";
            DUIDRawData = "00:00:ab:11:30:a8:a9:28:56:de:e9:fe";
          };
          networks."40-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "ipv4";
              IPv6AcceptRA = true;
            };
            dhcpV4Config.IAID = lib.fromHexString "0x313149e";
          };
        };

        environment.systemPackages = with pkgs; [
          dig
          curl
          trippy
          ethtool
        ];

        time.timeZone = "Asia/Singapore";
        system.stateVersion = "25.11";
      };
    };
  };
}

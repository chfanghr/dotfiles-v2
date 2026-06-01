let
  vars = import ./netvars.nix;

  inherit
    (vars)
    phyIface
    mainVlanIface
    mgmtVlanIface
    phyNetKey
    mainVlanNetKey
    mgmtVlanNetKey
    ;

  mainVlanId = 42;
  mgmtVlanId = 120;

  containerPhyIface = "enp13s0f1np1";
  containerBridgeIface = "br-container";

  auxPhyIfaces = [
    "enp14s0"
    "enp15s0"
    "enp16s0"
  ];
in {
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
      ${mainVlanNetKey} = {
        netdevConfig = {
          Kind = "vlan";
          Name = mainVlanIface;
        };
        vlanConfig = {
          Id = mainVlanId;
        };
      };
      ${mgmtVlanNetKey} = {
        netdevConfig = {
          Kind = "vlan";
          Name = mgmtVlanIface;
        };
        vlanConfig = {
          Id = mgmtVlanId;
        };
      };
      # Container
      "40-${containerBridgeIface}" = {
        netdevConfig = {
          Kind = "bridge";
          Name = containerBridgeIface;
        };
        bridgeConfig = {
          DefaultPVID = mainVlanId;
          STP = true;
          # VLANFiltering = true;
        };
      };
    };
    networks = {
      # Host Interfaces
      ${phyNetKey} = {
        matchConfig.Name = phyIface;
        networkConfig = {
          LLDP = true;
          EmitLLDP = true;
          IPv6AcceptRA = false;
          LinkLocalAddressing = false;
          VLAN = [
            mainVlanIface
            mgmtVlanIface
          ];
        };
      };
      ${mainVlanNetKey} = {
        matchConfig.Name = mainVlanIface;
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = "kernel";
        };
      };
      ${mgmtVlanNetKey} = {
        matchConfig.Name = mgmtVlanIface;
        networkConfig = {
          LLDP = true;
          EmitLLDP = true;
          Address = "10.5.0.11/16";
          IPv6PrivacyExtensions = "kernel";
        };
      };
      # Container network
      "40-${containerPhyIface}" = {
        matchConfig.Name = containerPhyIface;
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig.Bridge = containerBridgeIface;
      };
      "40-${containerBridgeIface}" = {
        matchConfig.Name = containerBridgeIface;
        networkConfig = {
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          LinkLocalAddressing = false;
        };
        bridgeConfig.UseBPDU = true;
      };
      # Aux
      "40-aux" = {
        matchConfig.Name = auxPhyIfaces;
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
    hostBridge = containerBridgeIface;

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
}

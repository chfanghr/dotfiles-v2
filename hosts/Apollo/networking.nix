let
  phyIface = "enp13s0f0np0";
  mainVlanIface = "vlan-main";
  mgmtVlanIface = "vlan-mgmt";
in {
  networking = {
    useNetworkd = true;
    firewall.enable = true;
    nftables.enable = true;

    vlans = {
      ${mainVlanIface} = {
        id = 42;
        interface = phyIface;
      };
      ${mgmtVlanIface} = {
        id = 120;
        interface = phyIface;
      };
    };
    interfaces = {
      ${phyIface}.useDHCP = false;
      ${mainVlanIface}.useDHCP = true;
      ${mgmtVlanIface} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.5.0.11";
            prefixLength = 16;
          }
        ];
      };
    };
    enableIPv6 = true;
  };

  systemd.network.networks = {
    "40-${phyIface}" = {
      matchConfig.Name = phyIface;
      networkConfig = {
        LLDP = true;
        EmitLLDP = true;
        IPv6AcceptRA = false;
      };
    };
    "40-${mainVlanIface}" = {
      matchConfig.Name = mainVlanIface;
      networkConfig.IPv6AcceptRA = true;
    };
    "40-${mgmtVlanIface}" = {
      matchConfig.Name = mgmtVlanIface;
      networkConfig = {
        LLDP = true;
        EmitLLDP = true;
      };
    };
  };
}

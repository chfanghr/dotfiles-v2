{
  networking = {
    useNetworkd = true;
    firewall.enable = true;
    nftables.enable = true;
    vlans.vlan-main = {
      id = 42;
      interface = "enp13s0f0np0";
    };
    interfaces = {
      enp15s0.useDHCP = true;
      enp13s0f0np0.useDHCP = false;
      enp13s0f0np1.useDHCP = true;
      vlan-main.useDHCP = true;
    };
    enableIPv6 = true;
  };

  systemd.network.networks = {
    "40-enp13s0f0np0".networkConfig = {
      LLDP = true;
      EmitLLDP = true;
      IPv6AcceptRA = false;
    };
    "40-vlan-main".networkConfig = {
      IPv6AcceptRA = true;
    };
  };
}

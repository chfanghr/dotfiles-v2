{
  networking = {
    useNetworkd = true;
    firewall.enable = true;
    nftables.enable = true;
    interfaces.enp15s0.useDHCP = true;
  };
}

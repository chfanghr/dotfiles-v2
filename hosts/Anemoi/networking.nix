{
  networking = {
    useNetworkd = true;

    firewall.enable = true;
    nftables.enable = true;

    interfaces = {
      enp3s0 = {
        useDHCP = true;
      };
      enp2s0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.255.6";
            prefixLength = 24;
          }
        ];
      };
    };
  };
}

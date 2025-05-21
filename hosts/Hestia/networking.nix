{
  networking = {
    enableIPv6 = true;

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
}

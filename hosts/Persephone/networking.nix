{
  networking = {
    hostName = "Persephone";
    hostId = "9ce62f33"; # Required by zfs

    useNetworkd = true;

    bonds.bond0 = {
      interfaces = ["enp195s0f0" "enp195s0f1"];
      driverOptions = {
        mode = "802.3ad";
      };
    };
    interfaces.bond0.useDHCP = true;

    firewall.enable = true;
  };

  systemd.network.networks."40-enp33s0f3" = {
    matchConfig.Name = "enp33s0f3";
    dhcpV4Config.RouteMetric = 1025;
    networkConfig.DHCP = "ipv4";
  };

  boot = {
    kernelModules = ["tcp_bbr"];

    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd = {
      enable = true;
      extraArgs = ["-I" "bond0"];
    };
  };
}

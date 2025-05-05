{
  lib,
  config,
  ...
}: {
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
    interfaces = {
      bond0.useDHCP = true;
      enp33s0f3 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.255.4";
            prefixLength = 24;
          }
        ];
      };
    };

    firewall.enable = true;
  };

  # systemd.network.networks."40-enp33s0f3" = {
  #   matchConfig.Name = "enp33s0f3";
  #   dhcpV4Config.RouteMetric = 1025;
  #   networkConfig.DHCP = "ipv4";
  # };

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

  specialisation.staticIP.configuration = {
    networking = {
      interfaces.bond0 = {
        useDHCP = lib.mkForce false;
        ipv4.addresses = [
          {
            address = "10.41.255.234";
            prefixLength = 16;
          }
        ];
      };
      defaultGateway = {
        address = config.dotfiles.shared.networking.home.router.address;
        interface = "bond0";
      };
    };
  };
}

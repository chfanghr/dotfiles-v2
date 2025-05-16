{
  networking = {
    useNetworkd = true;

    nftables.enable = true;
    firewall.enable = true;

    bridges.br0.interfaces = [
      "enp3s0"
      "enp4s0"
      "enp5s0"
      "enp6s0"
    ];
    interfaces = {
      enp2s0.useDHCP = true;
      br0.useDHCP = true;
      enp7s0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.255.6";
            prefixLength = 16;
          }
        ];
      };
    };

    enableIPv6 = true;
  };

  systemd.network.networks = {
    "40-enp2s0".networkConfig.IPv6AcceptRA = true;
    "40-br0" = {
      networkConfig = {
        LLDP = true;
        EmitLLDP = true;
        IPv6AcceptRA = true;
      };
      dhcpV4Config = {
        UseGateway = true;
        UseDNS = true;
      };
      bridgeConfig.UseBPDU = true;
    };
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  containers.sim-lan-host = {
    autoStart = true;

    ephemeral = true;

    privateNetwork = true;
    hostBridge = "br0";

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

        nameservers = [
          "1.1.1.1"
          "233.5.5.5"
          "114.114.114.114"
        ];
      };

      services.resolved.enable = true;

      systemd.network = {
        wait-online.enable = false;
        config.dhcpV4Config = {
          DUIDType = "vendor";
          DUIDRawData = "00:00:ab:11:e2:b0:bd:3e:24:d6:14:67";
        };
        networks."40-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
          };
          dhcpV4Config.IAID = lib.fromHexString "0xb845eeea";
        };
      };

      environment.systemPackages = [
        pkgs.dig
        pkgs.curl
        pkgs.trippy
        pkgs.ethtool
      ];

      time.timeZone = "Asia/Hong_Kong";
      system.stateVersion = "24.11";
    };
  };
}

{
  pkgs,
  lib,
  ...
}: {
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

  services = {
    tailscale.useRoutingFeatures = lib.mkForce "both";

    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale-optimizations" = {
        onState = ["routable"];
        script = ''
          ${lib.getExe' pkgs.ethtool "ethtool"} -K enp3s0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };

  environment.defaultPackages = [
    pkgs.sbctl
    pkgs.ethtool
  ];
}

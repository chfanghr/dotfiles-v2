{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./backup.nix
    ./boot.nix
    ./disko.nix
    ./minecraft.nix
    ./qbittorrent.nix
    ./samba.nix
    ./stash.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
  ];

  dotfiles.nixos = {
    props = {
      hardware = {
        audio = true;
        bluetooth.enable = true;
        cpu.amd = true;
        gpu.amd.enable = true;
        emulation = true;
        vmHost = true;
      };
      nix.roles = {
        builder = true;
        consumer = true;
      };
      ociHost = true;
    };
    nix.builderPrivateKeyAgeSecret = ../../secrets/hestia-nix-cache-key.age;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$JK4s34tHJmsXrZkf/VUXt.$rokP.46N.fjjjxBjD/sD9XUyFkF18PPChA4Yviq5uGB";

  networking = {
    hostName = "Hestia";
    hostId = "5dc9aa9c";

    enableIPv6 = true;

    nftables.enable = true;
    firewall.enable = true;

    interfaces = {
      enp195s0.useDHCP = true;
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
  };

  systemd.network.networks."40-enp195s0".networkConfig.IPv6AcceptRA = true;

  environment.defaultPackages = [
    pkgs.vulkan-tools
    pkgs.nvtopPackages.amd
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
    tailscale-traefik.enable = true;
  };

  specialisation.desktop.configuration = {
    dotfiles.shared.props.purposes.graphical = {
      gaming = true;
      desktop = true;
    };

    home-manager.users.fanghr = {
      home.packages = [
        pkgs.qbittorrent
      ];
    };
  };
}

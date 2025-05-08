{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./qbittorrent.nix
    ./safe.nix
    ./samba.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  dotfiles = {
    shared.props.purposes.graphical = {
      gaming = true;
      desktop = true;
    };
    nixos = {
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
    };
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$JK4s34tHJmsXrZkf/VUXt.$rokP.46N.fjjjxBjD/sD9XUyFkF18PPChA4Yviq5uGB";

  networking = {
    hostName = "Hestia";
    hostId = "5dc9aa9c";

    enableIPv6 = true;

    interfaces.enp195s0 = {
      useDHCP = true;
      ipv4.addresses = [
        {
          address = "192.168.255.5";
          prefixLength = 24;
        }
      ];
    };
  };

  environment.defaultPackages = [
    pkgs.vulkan-tools
    pkgs.nvtopPackages.amd
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
  };
}

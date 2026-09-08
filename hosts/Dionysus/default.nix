{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./desktop.nix
    ./gaming.nix
    ./llm.nix
    ../../modules/nixos/common
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
  ];

  networking.hostName = "Dionysus";

  dotfiles = {
    shared.props = {
      locationName = "sg";
      purposes = {
        work = true;
        graphical = {
          gaming = lib.mkDefault true;
          desktop = lib.mkDefault true;
        };
      };
    };
    nixos.props = {
      hardware = {
        audio = true;
        bluetooth = {
          enable = true;
          blueman = true;
        };
        cpu.amd = true;
        gpu.nvidia = true;
        gpu.amd.enable = true;
        emulation = true;
        vmHost = true;
      };
      nix.roles.consumer = true;
      ociHost = true;
    };
  };

  users.users.fanghr.hashedPassword = "$y$j9T$SxmPzl.7ervjxa6Mzvq7p1$KLXfgvnEzCboA8TPWqGrEV/rn49v6uXiFSoIf7j5YGD";

  networking = {
    vlans = {
      "vlan-main" = {
        interface = "enp6s0f1np1";
        id = 42;
      };
      "vlan-mgmt" = {
        interface = "enp6s0f1np1";
        id = 120;
      };
    };
    interfaces = {
      "vlan-main".useDHCP = true;
      "vlan-mgmt" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.5.0.10";
            prefixLength = 16;
          }
        ];
      };
      "enp6s0f1np1".useDHCP = false;
    };
    firewall.trustedInterfaces = ["virbr0"];
  };

  services = {
    ucodenix.enable = true;

    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = [
    pkgs.vulkan-tools
    pkgs.nvtopPackages.full
  ];

  nix.settings = {
    download-buffer-size = 524288000;
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  virtualisation.libvirtd.qemu.vhostUserPackages = [pkgs.virtiofsd];

  specialisation = {
    debug.configuration = {
      dotfiles.shared.props.purposes.graphical = {
        desktop = false;
        gaming = false;
      };

      boot = {
        loader.systemd-boot.memtest86.enable = true;
        plymouth.enable = false;
      };

      networking.interfaces."enp6s0f0np0".useDHCP = true;
    };
  };

  dotfiles.shared.nixpkgs-unstable.config.allowUnfree = true;
}

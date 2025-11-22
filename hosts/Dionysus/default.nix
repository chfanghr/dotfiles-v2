{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ../../modules/nixos/common
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
  ];

  networking.hostName = "Dionysus";

  dotfiles = {
    shared.props = {
      purposes = {
        work = true;
        graphical = {
          gaming = lib.mkDefault true;
          desktop = lib.mkDefault true;
        };
      };
    };
    nixos = {
      props = {
        hardware = {
          audio = true;
          bluetooth = {
            enable = true;
            blueman = true;
          };
          cpu.amd = true;
          gpu.amd.enable = true;
          emulation = true;
          vmHost = true;
        };
        nix.roles.consumer = true;
        ociHost = true;
      };
    };
  };

  networking = {
    vlans."vlan-main" = {
      interface = "enp6s0f1np1";
      id = 42;
    };
    interfaces = {
      "vlan-main".useDHCP = true;
      "enp6s0f1np1".useDHCP = false;
    };
  };

  users.users.fanghr.hashedPassword = "$y$j9T$SxmPzl.7ervjxa6Mzvq7p1$KLXfgvnEzCboA8TPWqGrEV/rn49v6uXiFSoIf7j5YGD";

  home-manager.users.fanghr.home.packages = [
    pkgs.handbrake
  ];

  systemd.tmpfiles.settings."10-game-backup"."/data/game-backup".d = {
    user = "fanghr";
    mode = "0700";
  };

  programs = {
    steam = {
      protontricks.enable = true;
    };

    kdeconnect.enable = true;
  };

  services = {
    sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    xserver.displayManager.startx.enable = true;

    ucodenix.enable = true;

    iperf3 = {
      enable = true;
      openFirewall = true;
    };

    avahi = {
      enable = lib.mkForce true;
      allowInterfaces = [
        "vlan-main"
      ];
    };
  };

  environment.systemPackages = [
    pkgs.vulkan-tools
    pkgs.nvtopPackages.amd
  ];

  nix.settings.download-buffer-size = 524288000;

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
}

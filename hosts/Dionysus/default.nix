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
      networking.home = {
        onLanNetwork = true;
        proxy.useGateway = false;
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
      networking.lanInterfaces = ["enp14s0"];
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
      enable = true;
      allowInterfaces = [
        "enp6s0f1np1"
        "enp6s0f1np0"
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
      };
    };
    amdvlk.configuration = {
      dotfiles.nixos.props.hardware.gpu.amd.amdvlk.enable = true;
    };
    useProxy.configuration = {
      dotfiles.shared.props.networking.home.proxy.useGateway = lib.mkForce true;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}

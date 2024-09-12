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

  programs.steam = {
    protontricks.enable = true;
  };

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  systemd.tmpfiles.settings."10-game-backup"."/data/game-backup".d = {
    user = "fanghr";
    mode = "0700";
  };

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
    zenKernel.configuration = {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    };
    latestKernel.configuration = {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}

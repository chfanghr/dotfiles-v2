{
  pkgs,
  lib,
  config,
  ...
}: {
  dotfiles.nixos.props.hardware.cpu.tweaks.amd.noPstate = true;

  specialisation = {
    zenKernel.configuration = {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    };
    latestKernel.configuration = {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };

  boot = let
    loadAllZfsKeys = pkgs.writeScript "load-all-zfs-keys" ''
      ${lib.getExe config.boot.zfs.package} load-key -a
    '';
  in {
    initrd = {
      availableKernelModules = [
        "ixgbe" # 82599es
        "tg3" # BCM5719
        "megaraid_sas"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "ast"
      ];

      supportedFilesystems.zfs = true;

      systemd = {
        enable = true;
        network.enable = true;
        users.root.shell = "${loadAllZfsKeys}";
      };

      network.ssh = {
        enable = true;
        port = 2222;
        hostKeys = [
          # TODO(chfanghr): Use agenix
          "/etc/secrets/initrd/ssh_host_rsa_key"
          "/etc/secrets/initrd/ssh_host_ed25519_key"
        ];
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJnZjDdWnD6KdkEzCW2lZ3Zg7hSYtRYdRPoGJWuR3fJB5ZOYP/zAzGkJ+GngoBc2TAK6hGcZmP3ScLVXb6a12eLrqpNFuq4Ja0zDI+QhItr7WxgeXZcdnrgu8bZ7j70z+PrJq9ZzUVWG3EnnOkRpHG1NC45Bi7Y/sp7gQXrTYxOnq4Hvo4CeUdVno/ImmTgg63IW4qJYUJ+YidiUo5rslwFiVS8XgTJkI1zswvIkurQhWTUoX+nj/Oo7f1w41dwkbjXun44bXQIJO6jrKf8KY9gM1dIwK+pNWYOql/vnItsohlx7CwclwyJl4xcj/21gWgh8AXuJ+kWPPUnm2DrAnbDN2W/8kboa7DpFrg5oiDaLU9Q3n1abIBraujhY3pHEg8DYhLB4zqblHlUB2GmaZ9SkfDZyJ01CTuSUJHY/a3duGQGEBXOgWV32F9G5DcUHVr996/I4EMIuPFAbxMA7p4dO4i26y3mg/E6lIzMEGxy38Fg/0PVUEsI5tk6vIbPrI+AkDWIBjQwFodQaC1elXSFcwVD+Fx8bCQk2coFhO8fG1yr41AH3ZRg8i5MmaTSu49Pqj3wVRJs2NJKkh4Cm0LFJqmb6ReYK0KOqB/hLCXSYhrBmmS4/hwhqPZ3GRkzHWvwVk14yeDoLW7TchCr3L4a87jnXp3mkNnVGGwGgacMQ== cardno:19_342_978"
        ];
      };
    };

    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelParams = ["nohibernate"];

    supportedFilesystems = {
      zfs = true;
      btrfs = true;
    };

    zfs.forceImportAll = true;

    plymouth.enable = false;
  };

  fileSystems = {
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/var" = {
      device = "rpool/var";
      fsType = "zfs";
    };
    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "tank/nix";
      fsType = "zfs";
      options = ["noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/96CB-AEF3";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/ebbdd45a-ff71-4e5c-a4aa-ac604feb813d";}
  ];

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
    sanoid.enable = true;
  };

  powerManagement.cpuFreqGovernor = "ondemand";
}

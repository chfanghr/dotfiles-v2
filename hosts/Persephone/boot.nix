{
  pkgs,
  lib,
  config,
  ...
}: {
  dotfiles.nixos.props.hardware.cpu.tweaks.amd.noPstate = true;

  boot = let
    mkLoadZfsKeys = pools: keysDataset: encRoots: let
      keysMP = "/zfs-keys";
    in
      pkgs.writeShellApplication
      {
        name = "load-zfs-keys";
        text = ''
          ${lib.concatMapStringsSep "\n" (p: "zpool import ${p} || true") pools}
          zfs load-key -L prompt ${keysDataset}
          mkdir -p ${keysMP}
          mount -t zfs -o ro ${keysDataset} ${keysMP}
          ${lib.pipe encRoots [
            (lib.mapAttrsToList (
              ds: k: "zfs load-key -L file://${keysMP}/${k} ${ds}"
            ))
            (lib.concatStringsSep "\n")
          ]}
          umount ${keysMP}
          zfs unload-key ${keysDataset}
          systemctl restart zfs-import-\*.service
        '';
        meta.description = ''
          Import all `pools`, then load all keys required by `encRoots`
          from `keysDataset`.

          `pools` should have type `listOf str`.

          `encRoots` should have type `attrsOf str`, where the keys are
          dataset to be unlocked, and their values are relative paths to the key
          files, in the `keysDataset` dataset.
        '';
      };

    loadZfsKeys = mkLoadZfsKeys config.boot.zfs.extraPools "rpool/zfs-keys" encryptionRoots;

    encryptionRoots = {
      "rpool/enc" = "rpool-enc-key";
      "vault" = "vault-key";
      "tank/enc" = "tank-enc-key";
    };

    zfsPools = [
      "rpool"
      "tank"
      "vault"
    ];
  in {
    useLatestZfsCompatibleKernel = true;

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
        network = {
          enable = true;
          networks."40-enp33s0f0" = {
            matchConfig.Name = "enp33s0f0";
            networkConfig.Address = "10.41.0.29/16";
          };
        };

        storePaths = [loadZfsKeys.outPath];

        services.zfs-remote-unlock = {
          description = "Prepare for ZFS remote unlock";
          wantedBy = ["initrd.target"];
          after = ["systemd-networkd.service"];
          serviceConfig.Type = "oneshot";
          script = ''
            echo "${lib.getExe loadZfsKeys}; exit 0" >> /var/empty/.profile
          '';
        };
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

    zfs = {
      extraPools = zfsPools;
      requestEncryptionCredentials = builtins.attrNames encryptionRoots;
    };

    plymouth.enable = false;
  };

  fileSystems = {
    "/" = {
      device = "rpool/enc/root";
      fsType = "zfs";
    };
    "/var" = {
      device = "rpool/enc/var";
      fsType = "zfs";
    };
    "/home" = {
      device = "rpool/enc/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
      options = ["noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/898A-B92A";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/166e185c-9ccf-4b12-a1d7-d700268af9cf";
      randomEncryption.enable = true;
    }
    {
      device = "/dev/disk/by-partuuid/923b468b-b5d7-4ee8-b599-2afbd6476718";
      randomEncryption.enable = true;
    }
  ];

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";
}

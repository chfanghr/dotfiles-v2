{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-CT1000P310SSD8_25124F63CB07";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "4G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          zfs-keys = {
            size = "128M";
            content = {
              type = "luks";
              name = "zfs-keys";
              content = {
                type = "filesystem";
                format = "ext4";
              };
            };
          };
          swap = {
            size = "32G";
            content = {
              type = "swap";
              randomEncryption = true;
              discardPolicy = "both";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool.rpool = {
      type = "zpool";

      options.ashift = "12";
      rootFsOptions.mountpoint = "none";

      postCreateHook = ''
        zfs list -t snapshot -H -o name | grep -E '^rpool/enc/root@blank$' \
          || zfs snapshot rpool/enc/root@blank
      '';

      datasets = {
        enc = {
          type = "zfs_fs";
          options = {
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "prompt";
            mountpoint = "none";
          };
        };
        "enc/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            canmount = "noauto";
            mountpoint = "legacy";
          };
        };
        "enc/home" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/home";
        };
        "enc/persist" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/persist";
        };

        nix = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
          mountpoint = "/nix";
        };

        reserved = {
          type = "zfs_volume";
          size = "16G";
        };
      };
    };
  };

  networking.hostId = "2e30674c";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };

  fileSystems."/persist".neededForBoot = true;
}

{config, ...}: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/ata-BKHD_mSATA_64G_RNG24060101511";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          swap = {
            size = "2G";
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
        zfs list -t snapshot -H -o name | grep -E '^rpool/root@blank$' \
          || zfs snapshot rpool/root@blank
      '';

      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            canmount = "noauto";
            mountpoint = "legacy";
          };
        };
        nix = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
          mountpoint = "/nix";
        };
        home = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/home";
        };
        persist = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = config.athena.persistPath;
        };
        reserved = {
          type = "zfs_volume";
          size = "1G";
        };
      };
    };
  };

  networking.hostId = "3fa873b3";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };

  fileSystems."/persist".neededForBoot = true;
}

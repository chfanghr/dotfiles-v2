{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Fisusen-128G_SRG03LCF0059";
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
          mountpoint = "/persist";
        };
        reserved = {
          type = "zfs_volume";
          size = "5G";
        };
      };
    };
  };

  networking.hostId = "085abd2f";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };

  fileSystems."/persist".neededForBoot = true;
}

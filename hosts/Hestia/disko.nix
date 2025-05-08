{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-ORICO-2TB_9J40626005205";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "4G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            primary = {
              end = "-128G";
              content = {
                type = "luks";
                name = "enc_root";
                settings.allowDiscards = true; # trim
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
              };
            };
          };
        };
      };
    };
    zpool.rpool = {
      type = "zpool";
      rootFsOptions = {
        mountpoint = "none";
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
        "com.sun:auto-snapshot" = "true";
      };
      options.ashift = "12";
      postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^rpool@blank$' || zfs snapshot rpool@blank";
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
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
        var = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/var";
        };
        backup = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            snapdir = "visible";
          };
        };
        qbittorrent = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
          mountpoint = "/mnt/qbittorrent";
        };
        reserved = {
          type = "zfs_volume";
          size = "32G";
        };
      };
    };
  };
}

{lib, ...}: let
  inherit (lib) optionalAttrs;

  mkSSD = boot: device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content =
            {
              type = "filesystem";
              format = "vfat";
            }
            // (optionalAttrs boot {
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            });
        };
        swap = {
          size = "16G";
          content = {
            type = "swap";
            discardPolicy = "both";
            randomEncryption = true;
          };
        };
        zp-mirrored-member = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zp-mirrored";
          };
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      ssd-1 = mkSSD true "/dev/disk/by-id/nvme-CT1000P310SSD8_2526511B3FF5";
      ssd-2 = mkSSD false "/dev/disk/by-id/nvme-CT1000P310SSD8_2526511B3186";
    };
    zpool = {
      zp-mirrored = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          mountpoint = "none";
          compression = "lz4";
          acltype = "posixacl";
          xattr = "sa";
        };
        options.ashift = "12";
        datasets = {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          "enc/root" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              canmount = "noauto";
            };
            mountpoint = "/";
          };
          "enc/home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
          "enc/var" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var";
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
            size = "32G";
          };
        };
      };
    };
  };

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };

  networking.hostId = "b6ef449b";
}

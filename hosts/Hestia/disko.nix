let
  zfsKeysMountpoint = "/zfs-keys";
in {
  disko.devices = {
    disk = {
      ssd-1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-ORICO-2TB_9J40626005205";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "4G";
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
                discardPolicy = "both";
                randomEncryption = true;
              };
            };
            zp-mirrored-member = {
              size = "256G";
              content = {
                type = "zfs";
                pool = "zp-mirrored";
              };
            };
            zp-striped-member = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zp-striped";
              };
            };
          };
        };
      };
      ssd-2 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-ORICO_DUVAKF2MAHTA3GE45IXU";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
              };
            };
            zp-mirrored-member = {
              size = "256G";
              content = {
                type = "zfs";
                pool = "zp-mirrored";
              };
            };
            zp-striped-member = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zp-striped";
              };
            };
          };
        };
      };
    };
    zpool = {
      zp-striped = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
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
              keylocation = "file:///${zfsKeysMountpoint}/zp-striped-enc-key";
              # keylocation = "prompt";
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
          "enc/qbittorrent" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
            mountpoint = "/data/qbittorrent";
          };
          "enc/zrepl".type = "zfs_fs";
          "enc/zrepl/vault/safe" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/data/safe";
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
      zp-mirrored = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
        };
        options = {
          cachefile = "none";
          ashift = "12";
        };
        datasets = {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///${zfsKeysMountpoint}/zp-mirrored-enc-key";
              # keylocation = "prompt";
            };
          };
          "enc/stash" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/data/stash";
          };
          "enc/minecraft" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/data/minecraft";
          };
          "enc/minecraft/smp" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/data/minecraft/smp";
          };

          reserved = {
            type = "zfs_volume";
            size = "5G";
          };
        };
      };
    };
  };

  # TODO: This should be handled by disko
  boot.initrd = {
    supportedFilesystems.ext4 = true;
    luks.devices.zfs-keys = {
      yubikey = {
        slot = 2;
        twoFactor = false;
        storage.device = "/dev/disk/by-partlabel/disk-ssd-1-esp";
      };
      postOpenCommands = ''
        mkdir -p /zfs-keys
        mount -t ext4 -o ro /dev/mapper/zfs-keys /zfs-keys || (dmesg && exit 1)
        zpool import -f -a
        zfs load-key -a
        umount /zfs-keys
        cryptsetup close zfs-keys
      '';
    };
  };

  fileSystems."/data/minecraft/smp".depends = [
    "/data/minecraft"
  ];

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };

  networking.hostId = "5dc9aa9c";
}

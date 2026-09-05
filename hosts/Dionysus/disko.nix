{lib, ...}: let
  inherit (lib) optionalAttrs;

  mkDiskPathById = id: "/dev/disk/by-id/${id}";

  rootPool = "dionysus-root";
  fastPool = "dionysus-fast";
  slowPool = "dionysus-slow";

  fastMp = "/data/fast";
  slowMp = "/data/slow";
  mpRuleDefault = {
    d = {
      user = "fanghr";
      mode = "0700";
    };
  };

  mkRootPoolDev = {
    isBootDrive ? false,
    id,
  }: {
    type = "disk";
    device = mkDiskPathById id;
    content = {
      type = "gpt";
      partitions = (
        {
          zfs = {
            size = "900G";
            content = {
              type = "zfs";
              pool = rootPool;
            };
          };
          swap = {
            size = "24G";
            content = {
              type = "swap";
              discardPolicy = "both";
              randomEncryption = true;
            };
          };
        }
        // (optionalAttrs isBootDrive {
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
        })
      );
    };
  };
  mkFastPoolDev = {id}:
    mkWholeDiskZPoolMember {
      inherit id;
      pool = fastPool;
    };
  mkSlowPoolDev = {id}:
    mkWholeDiskZPoolMember {
      inherit id;
      pool = slowPool;
    };

  mkWholeDiskZPoolMember = {
    id,
    pool,
  }: {
    type = "disk";
    device = mkDiskPathById id;
    content = {
      type = "gpt";
      partitions.zfs = {
        size = "100%";
        content = {
          type = "zfs";
          inherit pool;
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      ssd-1 = mkRootPoolDev {id = "nvme-KIOXIA-EXCERIA_PLUS_G2_SSD_72RB40WBKS92";};
      ssd-2 = mkRootPoolDev {
        id = "nvme-WDS100T3X0C-00SJG0_212201A00754";
        isBootDrive = true;
      };

      ssd-3 = mkFastPoolDev {id = "nvme-CT2000T500SSD8_25285173D11B";};
      ssd-4 = mkFastPoolDev {id = "nvme-CT2000T500SSD8_240346494D26";};

      ssd-5 = mkSlowPoolDev {id = "ata-KIOXIA-EXCERIA_SATA_SSD_62EB81STK0Z5";};
    };

    zpool = {
      ${rootPool} = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
              compression = "lz4";
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
          "enc/var" = {
            type = "zfs_fs";
          };
          "enc/var/lib" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var/lib";
          };
          "enc/var/log" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var/log";
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
      ${fastPool} = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = fastMp;
          compression = "zstd";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
      };
      ${slowPool} = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = slowMp;
          compression = "zstd";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
      };
    };
  };

  systemd.tmpfiles.settings."10-mountpoints" = {
    ${slowMp} = mpRuleDefault;
    ${fastMp} = mpRuleDefault;
  };

  boot.zfs = {
    extraPools = [
      fastPool
      slowPool
    ];

    requestEncryptionCredentials = ["${rootPool}/enc"];
  };

  services = {
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
    smartd.enable = true;
  };

  networking.hostId = "1c6dac63";
}

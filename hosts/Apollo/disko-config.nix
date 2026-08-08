{config, ...}: let
  mkDiskPathById = id: "/dev/disk/by-id/${id}";
  wholeDiskZPoolMember = id: pool: {
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

  zfsKeys = "/etc/secrets/zfs-keys/";

  dpool = "dpool";
  spool = "spool";
  rpool = "rpool";
  fpool = "fpool";
in {
  disko.devices = {
    disk = {
      hdd-1 = wholeDiskZPoolMember "ata-TOSHIBA_HDWG51GUZSVA_1672A00UFWRH" dpool;
      hdd-2 = wholeDiskZPoolMember "ata-TOSHIBA_HDWG51GUZSVA_1672A02KFWRH" dpool;
      hdd-3 = wholeDiskZPoolMember "ata-TOSHIBA_HDWG51GUZSVA_1672A02FFWRH" dpool;
      hdd-4 = wholeDiskZPoolMember "ata-WDC_WUH721414ALE6L4_9MG6JYGA" spool;
      hdd-5 = wholeDiskZPoolMember "ata-WDC_WUH721414ALE6L4_9MG6LJ9A" spool;
      ssd-6 = wholeDiskZPoolMember "ata-ORICO_260203GH25602665" spool;
      ssd-7 = wholeDiskZPoolMember "ata-ORICO_260129FS25600312" dpool;
      ssd-8 = wholeDiskZPoolMember "ata-ORICO_MQ42W26901557" dpool;
      ssd-9 = wholeDiskZPoolMember "ata-ORICO_MQ42W26910168" dpool;
      ssd-10 = wholeDiskZPoolMember "nvme-CT1000P310SSD8_254253C06CCD" rpool;
      ssd-11 = wholeDiskZPoolMember "nvme-CT1000P310SSD8_25124F63CB07" rpool;
      ssd-12 = {
        type = "disk";
        device = mkDiskPathById "nvme-BC711_NVMe_SK_hynix_128GB____CYA3N039910303D3V";
        content = {
          type = "gpt";
          partitions.ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            size = "100%";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
        };
      };
      ssd-13 = {
        type = "disk";
        device = mkDiskPathById "nvme-CT1000P3PSSD8_25144F6CADD9";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              size = "128G";
              content = {
                type = "swap";
                randomEncryption = true;
                discardPolicy = "both";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = fpool;
              };
            };
          };
        };
      };
    };

    zpool = {
      ${spool} = {
        type = "zpool";

        mode.topology = {
          type = "topology";
          vdev = [
            {
              members = [
                "hdd-4"
                "hdd-5"
              ];
            }
          ];
          special = [{members = ["ssd-6"];}];
        };

        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions.mountpoint = "none";

        datasets = {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file://${zfsKeys}/${spool}-enc";
              compression = "lz4";
            };
          };
          "enc/qbittorrent" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = config.apollo.mountpoints.qbittorrent;
          };
          reserved = {
            type = "zfs_volume";
            size = "16G";
          };
        };
      };

      ${dpool} = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions.mountpoint = "none";
        mode.topology = {
          type = "topology";
          vdev = [
            {
              mode = "raidz1";
              members = [
                "hdd-1"
                "hdd-2"
                "hdd-3"
              ];
            }
          ];
          special = [
            {
              mode = "raidz1";
              members = [
                "ssd-7"
                "ssd-8"
                "ssd-9"
              ];
            }
          ];
        };
        datasets = {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file://${zfsKeys}/${dpool}-enc";
            };
          };
          "enc/comics" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = config.apollo.mountpoints.yac;
          };
          "enc/darwin-backups" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "enc/darwin-backups/hera" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = config.apollo.mountpoints.darwin-backups.hera;
          };
          "enc/darwin-backups/dioscuri" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = config.apollo.mountpoints.darwin-backups.dioscuri;
          };
          "enc/slow-stash" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = config.apollo.mountpoints.slow-stash;
          };
          reserved = {
            type = "zfs_volume";
            size = "16G";
          };
        };
      };

      ${rpool} = {
        type = "zpool";

        mode.topology = {
          type = "topology";
          vdev = [
            {
              mode = "mirror";
              members = [
                "ssd-10"
                "ssd-11"
              ];
            }
          ];
        };

        options.ashift = "12";
        rootFsOptions.mountpoint = "none";

        postCreateHook = ''
          zfs list -t snapshot -H -o name | grep -E '^${rpool}/enc/root@blank$' \
            || zfs snapshot ${rpool}/enc/root@blank
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
            mountpoint = config.apollo.mountpoints.persist;
          };

          "enc/minecraft" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "enc/minecraft/main-smp" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = config.apollo.mountpoints.minecraft.main-smp;
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

      ${fpool} = {
        type = "zpool";

        options.ashift = "12";
        rootFsOptions.mountpoint = "none";

        datasets = {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file://${zfsKeys}/${fpool}-enc";
              compression = "lz4";
            };
          };
          "enc/hercules-ci" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
          };
        };
      };
    };
  };

  networking.hostId = "2e30674c";

  services = {
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
    smartd.enable = true;
  };

  boot.zfs = {
    extraPools = [
      dpool
      spool
    ];
    requestEncryptionCredentials = [
      "${rpool}/enc"
      "${dpool}/enc"
      "${spool}/enc"
    ];
    forceImportAll = true;
  };

  systemd.services = {
    "zfs-import-${dpool}".after = ["etc-secrets-zfs\\x2dkeys.mount"];
    "zfs-import-${spool}".after = ["etc-secrets-zfs\\x2dkeys.mount"];
    "zfs-import-${fpool}".after = ["etc-secrets-zfs\\x2dkeys.mount"];
  };

  environment.persistence.${config.apollo.mountpoints.persist}.directories = [
    {
      directory = zfsKeys;
      mode = "u=rwx,g=,o=";
    }
  ];
}

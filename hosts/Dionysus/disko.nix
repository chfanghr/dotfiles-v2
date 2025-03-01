{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-CT2000T500SSD8_240346494D26";
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
              end = "-64G";
              content = {
                type = "luks";
                name = "enc_root";
                settings.allowDiscards = true; # trim
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "/rootfs" = {
                      mountpoint = "/";
                    };
                    "/home" = {
                      mountOptions = ["compress=zstd"];
                      mountpoint = "/home";
                    };
                    "/var" = {
                      mountOptions = ["compress=zstd"];
                      mountpoint = "/var";
                    };
                    "/nix" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/nix";
                    };
                  };
                };
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
      gameBackup = {
        device = "/dev/disk/by-id/ata-KIOXIA-EXCERIA_SATA_SSD_62EB81STK0Z5";
        content = {
          type = "gpt";
          partitions.primary = {
            size = "100%";
            content = {
              type = "btrfs";
              mountpoint = "/data/game-backup";
              mountOptions = ["compress=zstd" "noatime"];
            };
          };
        };
      };
      games = {
        device = "/dev/disk/by-id/nvme-KIOXIA-EXCERIA_PLUS_G2_SSD_72RB40WBKS92";
        content = {
          type = "gpt";
          partitions.primary = {
            size = "100%";
            content = {
              type = "btrfs";
              mountpoint = "/data/games";
              mountOptions = ["compress=zstd" "noatime"];
            };
          };
        };
      };
    };
  };
}

{
  poolName,
  mountPoints ? {},
  lib,
  ...
}: let
  inherit (lib) nameValuePair optionalAttrs;
  inherit (builtins) toString listToAttrs;

  mkDiskInEnclosure = i:
    nameValuePair "enclosure-${toString i}" {
      type = "disk";
      device = "/dev/disk/by-id/usb-ACASIS_EC-73520_000000000216-0:${toString i}";
      content = {
        type = "gpt";
        partitions.z-enclosure-member = {
          size = "100%";
          content = {
            type = "zfs";
            pool = poolName;
          };
        };
      };
    };

  mountPointsFinal =
    ({
      qbittorrent ? null,
      safe ? null,
      slowStash ? null,
      ...
    }: {
      inherit qbittorrent safe slowStash;
    })
    mountPoints;

  mkEncDataset = name: options: mountPoint:
    nameValuePair name ({
        type = "zfs_fs";
        options = {mountpoint = "legacy";} // options;
      }
      // optionalAttrs (mountPoint != null) {
        mountpoint = mountPoint;
        mountOptions = ["x-systemd.automount" "noauto"];
      });
in {
  disko.devices = {
    disk = listToAttrs [
      (mkDiskInEnclosure 0)
      (mkDiskInEnclosure 1)
    ];
    zpool.${poolName} = {
      type = "zpool";
      mode = "mirror";
      rootFsOptions = {
        mountpoint = "none";
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
      };
      datasets =
        {
          enc = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          reserved = {
            type = "zfs_volume";
            size = "32G";
          };
        }
        // (listToAttrs [
          (mkEncDataset "enc/qbittorrent" {atime = "off";} mountPointsFinal.qbittorrent)
          (mkEncDataset "enc/safe" {} mountPointsFinal.safe)
          (mkEncDataset "enc/slow_stash" {} mountPointsFinal.slowStash)
        ]);
    };
  };
}

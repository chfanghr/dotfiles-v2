{
  poolName,
  qbtMountPoint,
  safeMountPoint,
}: {lib, ...}: let
  inherit (lib) nameValuePair;
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
in {
  disko.devices = {
    disk = listToAttrs [
      (mkDiskInEnclosure 0)
      (mkDiskInEnclosure 1)
    ];
    zpool.${poolName} = {
      type = "zpool";
      rootFsOptions = {
        mountpoint = "none";
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
      };
      datasets = {
        enc = {
          type = "zfs_fs";
          options = {
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "prompt";
          };
        };
        "enc/qbittorrent" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
          mountpoint = qbtMountPoint;
          mountOptions = ["x-systemd.automount" "noauto"];
        };
        "enc/safe" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = safeMountPoint;
          mountOptions = ["x-systemd.automount" "noauto"];
        };
        reserved = {
          type = "zfs_volume";
          size = "32G";
        };
      };
    };
  };
}

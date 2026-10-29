{config, ...}: let
  inherit (config.apollo.zfs) pools mkDatasetMountpoint;
  inherit (pools) slow;

  pool = slow;
  ds = "enc/comics";
in {
  disko.devices.zpool = {
    ${pool}.datasets.${ds} = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = mkDatasetMountpoint pool ds;
    };
  };

  systemd.tmpfiles.settings."10-comics-dataset-mountpoints" = {
    ${config.disko.devices.zpool.${pool}.datasets.${ds}.mountpoint} = {
      d = {
        user = "fanghr";
        mode = "0700";
      };
    };
  };
}

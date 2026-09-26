{
  pkgs,
  config,
  ...
}: let
  inherit (config.apollo.zfs) pools mkDatasetMountpoint;

  steamDataset = "steam";
  epicDataset = "epic";
  mkGameDataset = dataset: pool: {
    ${dataset} = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = mkDatasetMountpoint pool dataset;
    };
  };

  mpRuleDefault = {
    d = {
      user = "fanghr";
      mode = "0700";
    };
  };
in {
  programs.steam.protontricks.enable = true;

  home-manager.users.fanghr.home.packages = [pkgs.boxflat];

  services.udev.packages = [pkgs.boxflat];

  disko.devices.zpool = {
    ${pools.fast}.datasets = mkGameDataset steamDataset pools.fast;
    ${pools.slow}.datasets =
      (mkGameDataset steamDataset pools.slow)
      // (mkGameDataset epicDataset pools.slow);
  };

  systemd.tmpfiles.settings."10-gaming-dataset-mountpoints" = {
    ${config.disko.devices.zpool.${pools.fast}.datasets.${steamDataset}.mountpoint} = mpRuleDefault;
    ${config.disko.devices.zpool.${pools.slow}.datasets.${steamDataset}.mountpoint} = mpRuleDefault;
    ${config.disko.devices.zpool.${pools.slow}.datasets.${epicDataset}.mountpoint} = mpRuleDefault;
  };
}

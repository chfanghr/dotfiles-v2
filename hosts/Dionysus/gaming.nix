{
  pkgs,
  config,
  ...
}: let
  inherit (config.apollo.zfs) pools mkDatasetMountpoint;

  dataset = "steam";
  mkSteamDatasets = pool: {
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
    ${pools.fast}.datasets = mkSteamDatasets pools.fast;
    ${pools.slow}.datasets = mkSteamDatasets pools.slow;
  };

  systemd.tmpfiles.settings."10-steam-dataset-mountpoints" = {
    ${config.disko.devices.zpool.${pools.fast}.datasets.${dataset}.mountpoint} = mpRuleDefault;
    ${config.disko.devices.zpool.${pools.slow}.datasets.${dataset}.mountpoint} = mpRuleDefault;
  };
}

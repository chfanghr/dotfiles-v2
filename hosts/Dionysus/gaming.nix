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

  boot.kernelModules = ["uinput"];

  users.users.fanghr.extraGroups = ["input" "plugdev" "adbusers"];

  services = {
    udev.packages = [pkgs.boxflat];

    wivrn = {
      enable = true;
      package = pkgs.wivrn.override {cudaSupport = true;};

      autoStart = true;
      openFirewall = true;

      highPriority = true;

      steam = {
        enable = true;
        importOXRRuntimes = true;
      };

      config = {
        enable = true;
        json = {
          application = [pkgs.wayvr];
        };
      };
    };
  };

  environment.systemPackages = [
    pkgs.wayvr
    pkgs.opencomposite
    pkgs.android-tools
  ];

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

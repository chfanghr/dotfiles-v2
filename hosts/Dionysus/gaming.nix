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
  programs.steam.package = pkgs.steam.override {
    # Ensure Steam and its pressure-vessel game containers discover WiVRn
    # even when Steam is started outside the login environment.
    extraEnv.PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
  };

  home-manager.users.fanghr.home.packages = [pkgs.boxflat];

  boot.kernelModules = ["uinput"];

  users.users.fanghr.extraGroups = ["input" "plugdev" "adbusers"];

  services = {
    udev.packages = [pkgs.boxflat];

    wivrn = {
      enable = true;
      # package = wivrn;

      autoStart = true;
      openFirewall = true;

      highPriority = true;

      # monadoEnvironment.XR_RUNTIME_JSON = "${wivrn}/share/openxr/1/openxr_wivrn.json";

      steam = {
        enable = true;
        importOXRRuntimes = true;
      };

      # config = {
      #   enable = true;
      #   json = {
      #     application = [pkgs.wayvr];
      #   };
      # };
    };
  };

  environment.systemPackages = [
    pkgs.wayvr
    pkgs.xrizer
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

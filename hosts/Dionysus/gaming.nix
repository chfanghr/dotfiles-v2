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

  wivrnRun = pkgs.writeShellScriptBin "wivrn-run" ''
    env XR_RUNTIME_JSON=${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc "$@"
  '';
in {
  programs.steam = {
    protontricks.enable = true;
    package = pkgs.steam.override {
      # Ensure Steam and its pressure-vessel game containers discover WiVRn
      # even when Steam is started outside the login environment.
      #
      # TODO: is this really necessary?
      extraEnv.PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
    };
    extraPackages = [
      wivrnRun
    ];
  };

  home-manager.users.fanghr.home.packages = [
    pkgs.boxflat
    pkgs.wayvr
    pkgs.android-tools
    wivrnRun
    config.dotfiles.shared.nixpkgs-unstable.pkgs.protonup-rs
  ];

  boot.kernelModules = ["uinput"];

  users.users.fanghr.extraGroups = ["input" "plugdev" "adbusers"];

  services = {
    udev.packages = [pkgs.boxflat];

    wivrn = {
      enable = true;

      autoStart = true;
      openFirewall = true;

      highPriority = true;

      steam = {
        enable = true;
        importOXRRuntimes = true;
      };
    };
  };

  environment.systemPackages = [
    pkgs.xrizer
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

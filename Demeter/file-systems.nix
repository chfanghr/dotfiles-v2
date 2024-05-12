{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption optional;
  fsDescType = types.submodule {
    options = {
      device = mkOption {
        type = types.path;
      };
      fsType = mkOption {
        type = types.str;
      };
      options = mkOption {
        type = types.listOf types.str;
        default = ["defaults"];
      };
    };
  };

  swapDescType = types.submodule {
    options = {
      device = mkOption {
        type = types.path;
      };
    };
  };

  cfg = config.demeter.fileSystems;

  mkSubvolOnRootBtrfs = name: noatime: {
    device = cfg.btrfsRoot.device;
    fsType = "btrfs";
    options = ["subvol=${cfg.btrfsRoot.${name}.subvol}"] ++ optional noatime "noatime";
  };

  allFileSystems = {
    "/boot" = {
      device = cfg.boot.device;
      fsType = "vfat";
    };

    "/" = mkSubvolOnRootBtrfs "root" true;
    "/home" = mkSubvolOnRootBtrfs "home" false;
    "/nix" = mkSubvolOnRootBtrfs "nix" true;
  };

  allSwapDevices = [
    {
      device = cfg.swap.device;
    }
  ];
in {
  options.demeter.fileSystems = {
    btrfsRoot = {
      device = mkOption {
        type = types.path;
      };

      root.subvol = mkOption {
        type = types.str;
      };

      home.subvol = mkOption {
        type = types.str;
      };

      nix.subvol = mkOption {
        type = types.str;
      };
    };

    swap.device = mkOption {
      type = types.path;
    };

    boot.device = mkOption {
      type = types.path;
    };

    allFileSystems = mkOption {
      type = types.attrsOf fsDescType;
      readOnly = true;
      default = allFileSystems;
    };

    allSwapDevices = mkOption {
      type = types.listOf swapDescType;
      readOnly = true;
      default = allSwapDevices;
    };
  };

  config = {
    fileSystems = cfg.allFileSystems;
    swapDevices = cfg.allSwapDevices;

    services.fstrim.enable = true;

    demeter.fileSystems = {
      boot.device = "/dev/disk/by-uuid/3AAF-0A9F";
      btrfsRoot = {
        device = "/dev/disk/by-uuid/91a87427-5393-43c3-956e-9291796f1557";
        root.subvol = "root";
        home.subvol = "home";
        nix.subvol = "nix";
      };
      swap.device = "/dev/disk/by-uuid/1455b8b6-d950-4a5f-9dcc-018b158ab109";
    };
  };
}

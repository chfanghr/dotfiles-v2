{
  imports = [
    ../../modules/nixos/common
    ../../modules/nixos/steamdeck.nix
  ];

  networking.hostName = "Jupiter";

  dotfiles = {
    shared.props = {
      purposes.graphical = {
        gaming = true;
        desktop = true;
      };
      hardware.steamdeck = true;
    };
    nixos.props = {
      hardware.bluetooth.enable = true;
      nix.roles.consumer = true;
      users.rootAccess = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e8dca5be-c18f-48e9-97f1-19378d074ddf";
    fsType = "btrfs";
    options = ["compress=zstd" "subvol=root"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e8dca5be-c18f-48e9-97f1-19378d074ddf";
    fsType = "btrfs";
    options = ["compress=zstd" "subvol=home"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e8dca5be-c18f-48e9-97f1-19378d074ddf";
    fsType = "btrfs";
    options = ["compress=zstd" "subvol=nix" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2751-8C7E";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/e4a1a7b5-2725-48e6-b584-90bfbce11f6f";}
  ];

  time.timeZone = "Asia/Hong_Kong";

  users.users = {
    fanghr.hashedPassword = "$y$j9T$YWaZAEKSBQUboCkBuV290/$TU1QhqJ2WDvf3WPrkwNFCmYuKJt5lTPIVNzkeOhzcc.";
    root.hashedPassword = "$y$j9T$LKaeyc.DQ7EM5DpX814SH1$XVrKrfoNe8DRlov5LBQPt13ChJS1o0N0MrM1bhPYZm3";
  };
}

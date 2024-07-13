{
  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/3cbbd538-ffc5-4a46-b3f3-a30068f213af";

  fileSystems."/" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = ["subvol=home"];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = ["subvol=nix"];
  };

  fileSystems."/persist" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = ["subvol=persist"];
  };

  fileSystems."/var/log" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = ["subvol=log"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/89C7-9E7E";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/106f9e04-4417-455e-8f5c-ba6eb6ebfb9e";}];
}

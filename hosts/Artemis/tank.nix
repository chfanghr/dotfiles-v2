{
  services.btrfs.autoScrub.enable = true;

  fileSystems."/mnt/tank" = {
    device = "/dev/mapper/yotsuba1";
    fsType = "btrfs";
    options = ["subvol=tank"];
  };
}

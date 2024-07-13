{
  services.btrfs.autoScrub.enable = true;

  fileSystems."/mnt/tank" = {
    device = "/dev/mapper/yotsuba1";
    fsType = "btrfs";
    options = ["subvol=tank"];
  };

  services.samba.shares = {
    tank = {
      path = "/mnt/tank";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "fanghr";
      writeable = "yes";
    };
    guest = {
      path = "/mnt/tank/Guest";
      browseable = "yes";
      "guest ok" = "yes";
      writeable = "no";
    };
  };
}

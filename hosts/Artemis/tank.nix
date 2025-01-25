{
  users.groups.smb-users.members = [
    "fanghr"
    "fry"
  ];

  systemd.tmpfiles.settings."10-tank" = {
    "/data/tank/main".d = {
      user = "root";
      group = "smb-users";
      mode = "0770";
    };
    "/data/tank/subterranean".d = {
      user = "root";
      group = "smb-users";
      mode = "0770";
    };
  };

  fileSystems = {
    "/data/tank/main" = {
      device = "tank/main";
      fsType = "zfs";
      options = ["noexec"];
    };
    "/data/tank/subterranean" = {
      device = "tank/subterranean";
      fsType = "zfs";
      options = ["noexec"];
    };
  };

  services.samba.settings = {
    main = {
      path = "/data/tank/main";
      "read only" = "no";
      "create mask" = "0755";
    };
    subterranean = {
      path = "/data/tank/subterranean";
      "read only" = "no";
      "create mask" = "0755";
    };
  };
}

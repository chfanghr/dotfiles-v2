{
  users.groups.smb-users.members = [
    "fanghr"
    "fry"
  ];

  systemd.tmpfiles.settings."10-vault" = {
    "/data/tank/main".d = {
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
  };

  services.samba.settings = {
    main = {
      path = "/data/tank/main";
      "read only" = "no";
      "create mask" = "0755";
    };
  };
}

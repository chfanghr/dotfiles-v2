{
  systemd.tmpfiles.settings."10-vault" = {
    "/data/collections".d = {
      user = "fanghr";
      group = "root";
      mode = "0700";
    };
    "/data/music".d = {
      user = "fanghr";
      group = "users";
      mode = "0755";
    };
    "/data/nfs-test".d = {
      user = "nobody";
      group = "nogroup";
      mode = "0777";
    };
  };

  fileSystems = {
    "/data/collections" = {
      device = "tank/enc/collections";
      fsType = "zfs";
      options = ["noexec"];
    };
    "/data/music" = {
      device = "tank/music";
      fsType = "zfs";
      options = ["noexec"];
    };
    "/data/nfs-test" = {
      device = "tank/nfs-test";
      fsType = "zfs";
      options = ["noexec"];
    };
  };

  services.samba.settings = {
    music = {
      path = "/data/music";
      "read only" = "no";
      "guest ok" = "yes";
      "read list" = "nobody guest";
      "write list" = "fanghr";
      "create mask" = "0755";
    };
    collections = {
      path = "/data/collections";
      "read only" = "no";
    };
  };

  services.minidlna.settings.media_dir = [
    "A,/data/music"
  ];
}

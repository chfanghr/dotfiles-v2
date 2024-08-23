# let datasets = {
#   music = {
#     mountPoint = "/data/music";
#     dataset = "tank/music";
#     user = "nobody";
#     group = "nobody";
#   };
#   steam = {
#     mountPoint = "/data/steam";
#     dataset = "tank/steam";
#     user = "nobody";
#     group = "nobody";
#   };
# }; in
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
  };

  services.samba.shares = {
    music = {
      path = "/data/music";
      browsable = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "read list" = "nobody guest";
      "write list" = "fanghr";
      "create mask" = "0755";
    };
    collections = {
      path = "/data/collections";
      browsable = "yes";
      "read only" = "no";
      "guest ok" = "no";
    };
  };

  services.minidlna.settings.media_dir = [
    "A,/data/music"
  ];
}

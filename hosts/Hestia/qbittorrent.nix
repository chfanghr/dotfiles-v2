let
  dataMountpoint = "/mnt/qbittorrent";

  qbtUser = "qbittorrent";
  qbtGroup = "qbittorrent";
  qbtUid = 995;
  qbtGid = 992;
in {
  users = {
    users.${qbtUser} = {
      uid = qbtUid;
      group = qbtGroup;
      isSystemUser = true;
    };

    groups.${qbtGroup}.gid = qbtGid;
  };

  services.samba.settings = {
    qbittorrent = {
      path = "${dataMountpoint}/downloads";
    };
  };

  systemd.tmpfiles.settings."10-qbittorrent-data".${dataMountpoint}.d = {
    user = qbtUser;
    group = qbtGroup;
    mode = "0775";
  };
}

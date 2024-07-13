{
  services.qbittorrent = {
    enable = true;
    dataDir = "/mnt/qbittorrent";
    user = "qbittorrent";
    group = "qbittorrent";
    openFilesLimit = 65536;
    port = 8080;
    openFirewall = true;
  };

  fileSystems."/mnt/qbittorrent" = {
    device = "/dev/mapper/yotsuba1";
    fsType = "btrfs";
    options = ["subvol=qbittorrent"];
  };

  services.samba.shares.qbittorrent = {
    path = "/mnt/qbittorrent/downloads";
    browseable = "yes";
    "read only" = "yes";
    "guest ok" = "no";
  };

  services.samba.shares.pending_torrents = {
    path = "/mnt/qbittorrent/to_be_downloaded/";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
  };
}

{config, ...}: let
  dataDir = "/data/jellyfin";
in {
  systemd.tmpfiles.settings."10-jellyfin-data".${dataDir}.d = {
    inherit (config.services.jellyfin) user group;
    mode = "0775";
  };

  fileSystems.${dataDir} = {
    device = "tank/enc/jellyfin";
    fsType = "zfs";
    options = ["noatime" "noexec"];
  };

  services.jellyfin = {
    enable = false;
    inherit dataDir;
  };

  # systemd.services.jellyfin.after = ["data-jellyfin.mount"];
}

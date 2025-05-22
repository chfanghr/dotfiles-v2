let
  stashMountpoint = "/data/stash";
in {
  systemd.tmpfiles.settings."10-stash".${stashMountpoint}.d = {
    user = "fanghr";
    group = "root";
    mode = "0700";
  };

  services.samba.settings.stash = {
    path = stashMountpoint;
    "read only" = "no";
    "force create mode" = "0600";
    "force directory mode" = "0700";
    "force user" = "fanghr";
    "force group" = "root";
  };
}

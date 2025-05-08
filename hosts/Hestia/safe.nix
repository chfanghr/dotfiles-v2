let
  safeMountpoint = "/mnt/safe";
in {
  systemd.tmpfiles.settings."10-safe".${safeMountpoint}.d = {
    user = "fanghr";
    group = "fanghr";
    mode = "0775";
  };
  services.samba.settings = {
    safe = {
      path = safeMountpoint;
      browsable = "no";
      "read only" = "no";
      "force create mode" = "0600";
      "force directory mode" = "0700";
      "force group" = "root";
      "force user" = "fanghr";
    };
  };
}

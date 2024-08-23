let
  safeMountPoint = "/data/safe";
  heraMountPoint = "/data/hera";
in {
  services.sanoid.datasets."vault/safe" = {
    daily = 30;
    hourly = 48;
    autosnap = true;
    autoprune = true;
  };

  systemd.tmpfiles.settings."10-vault" = {
    ${safeMountPoint}.d = {
      user = "fanghr";
      group = "root";
      mode = "0700";
    };
    ${heraMountPoint}.d = {
      user = "fanghr";
      group = "users";
      mode = "0700";
    };
  };

  fileSystems = {
    ${safeMountPoint} = {
      device = "vault/safe";
      fsType = "zfs";
      options = ["noexec"];
    };
    ${heraMountPoint} = {
      device = "vault/tm/hera";
      fsType = "zfs";
    };
  };

  services.samba.shares = {
    safe = {
      path = safeMountPoint;
      browsable = "no";
      "read only" = "no";
      "guest ok" = "no";
      "force create mode" = "0600";
      "force directory mode" = "0700";
      "force group" = "root";
    };
    hera = {
      path = heraMountPoint;
      browsable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "valid users" = "fanghr";
      public = "no";
      writeable = "yes";
      "force user" = "fanghr";
      "fruit:aapl" = "yes";
      "fruit:time machine" = "yes";
      "vfs objects" = "catia fruit streams_xattr";
    };
  };
}

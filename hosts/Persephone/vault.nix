let
  safeMountPoint = "/data/safe";
  heraMountPoint = "/data/hera";
  minecraftMainMountPoint = "/data/minecraft/main";
in {
  services.sanoid.datasets."vault/safe" = {
    daily = 30;
    hourly = 48;
    autosnap = true;
    autoprune = true;
  };

  systemd.tmpfiles.settings."10-vault" = {
    ${minecraftMainMountPoint}.d = {
      user = "fanghr";
      group = "root";
      mode = "0700";
    };
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
    ${minecraftMainMountPoint} = {
      device = "vault/minecraft/main";
      fsType = "zfs";
    };
  };

  services.samba.settings = {
    safe = {
      path = safeMountPoint;
      browsable = "no";
      "read only" = "no";
      "force create mode" = "0600";
      "force directory mode" = "0700";
      "force group" = "root";
    };
    hera = {
      path = heraMountPoint;
      browsable = "no";
      "read only" = "no";
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

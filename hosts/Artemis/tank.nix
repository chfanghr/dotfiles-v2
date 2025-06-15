{
  users = {
    users.cjx = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$mBAUblVg0KsB1rTSQDmPZ/$JELfuNvhO99smI.pRnUvBogk1gZWw3c/4jM6TDWdxiB";
    };

    groups.smb-users.members = [
      "fanghr"
      "fry"
      "cjx"
    ];
  };

  systemd.tmpfiles.settings."10-tank" = {
    "/data/tank/main".d = {
      user = "root";
      group = "smb-users";
      mode = "0770";
    };
    "/data/tank/subterranean".d = {
      user = "root";
      group = "smb-users";
      mode = "0770";
    };
    "/data/tank/cjx".d = {
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
    "/data/tank/subterranean" = {
      device = "tank/subterranean";
      fsType = "zfs";
      options = ["noexec"];
    };
    "/data/tank/cjx" = {
      device = "tank/cjx";
      fsType = "zfs";
      options = ["noexec"];
    };
  };

  services = {
    samba.settings = {
      main = {
        path = "/data/tank/main";
        "read only" = "no";
        "create mask" = "0755";
      };
      subterranean = {
        path = "/data/tank/subterranean";
        "read only" = "no";
        "create mask" = "0755";
      };
      cjx = {
        path = "/data/tank/cjx";
        "read only" = "no";
        "create mask" = "0755";
      };
    };
    zrepl = {
      settings.jobs = [
        {
          name = "periodic-snapshot-tank";
          type = "snap";
          filesystems."tank<" = true;
          snapshotting = {
            type = "periodic";
            interval = "10m";
            prefix = "zrepl_";
          };
          pruning.keep = [
            {
              type = "grid";
              grid = "16x1h(keep=all) | 24x1h | 35x1d | 12x30d";
              regex = "^zrepl_.*";
            }
            {
              type = "regex";
              regex = "^manual_.*";
            }
          ];
        }
      ];
    };
  };
}

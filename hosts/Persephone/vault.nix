{config, ...}: let
  safeMountPoint = "/data/safe";
  manualBackupMountPoint = "/data/manual-backup";
  heraMountPoint = "/data/hera";
  heraOldMountPoint = "/data/hera-old";
  minecraftMainMountPoint = "/data/minecraft/main";
in {
  systemd.tmpfiles.settings."10-vault" = {
    ${minecraftMainMountPoint}.d = {
      user = "minecraft-data";
      group = "nogroup";
      mode = "0700";
    };
    ${safeMountPoint}.d = {
      user = "fanghr";
      group = "root";
      mode = "0700";
    };
    ${manualBackupMountPoint}.d = {
      user = "fanghr";
      group = "root";
      mode = "0700";
    };
    ${heraMountPoint}.d = {
      user = "fanghr";
      group = "users";
      mode = "0700";
    };
    ${heraOldMountPoint}.d = {
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
    ${manualBackupMountPoint} = {
      device = "vault/manual-backup";
      fsType = "zfs";
      options = ["noexec"];
    };
    ${heraMountPoint} = {
      device = "vault/tm/hera";
      fsType = "zfs";
    };
    ${heraOldMountPoint} = {
      device = "vault/tm/hera-old";
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
    manual-backup = {
      path = manualBackupMountPoint;
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
    hera-old = {
      path = heraOldMountPoint;
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

  age.secrets."zrepl-persephone.snow-dace.ts.net.key".file = ../../secrets/zrepl-persephone.snow-dace.ts.net.key.age;

  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        {
          name = "safe-snapshots";
          type = "snap";
          filesystems = {
            "vault/safe" = true;
          };
          snapshotting = {
            type = "periodic";
            interval = "10m";
            prefix = "zrepl_";
          };
          pruning.keep = [
            {
              type = "regex";
              regex = "^manual_.*";
            }
            {
              type = "grid";
              grid = "1x1h(keep=all) | 24x1h | 14x1d";
              regex = "^zrepl_.*";
            }
          ];
        }
        {
          name = "minecraft-worlds-snapshots";
          type = "snap";
          filesystems = {
            "vault/minecraft<" = true;
          };
          snapshotting = {
            type = "periodic";
            interval = "1h";
            prefix = "zrepl_";
          };
          pruning.keep = [
            {
              type = "regex";
              regex = "^manual_.*";
            }
            {
              type = "grid";
              grid = "16x1h(keep=all) | 24x1h | 14x1d";
              regex = "^zrepl_.*";
            }
          ];
        }
        {
          name = "target_hestia";
          type = "source";
          serve = {
            type = "tls";
            listen = ":8888";
            ca = ../../secrets/zrepl-hestia.snow-dace.ts.net.crt;
            cert = ../../secrets/zrepl-persephone.snow-dace.ts.net.crt;
            key = config.age.secrets."zrepl-persephone.snow-dace.ts.net.key".path;
            client_cns = ["hestia.snow-dace.ts.net"];
          };
          filesystems."vault/safe" = true;
          snapshotting.type = "manual";
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8888];
}

{config, ...}: let
  safeMountPoint = "/mnt/safe";
in {
  systemd.tmpfiles.settings."10-backup".${safeMountPoint}.d = {
    user = "root";
    group = "root";
    mode = "0755";
  };

  age.secrets."zrepl-hestia.snow-dace.ts.net.key".file = ../../secrets/zrepl-hestia.snow-dace.ts.net.key.age;

  services = {
    samba.settings = {
      safe = {
        path = safeMountPoint;
        browsable = "no";
        "force group" = "root";
        "force user" = "fanghr";
      };
    };

    zrepl = {
      enable = true;

      settings.jobs = [
        {
          name = "source_persephone";
          type = "pull";
          connect = {
            type = "tls";
            address = "persephone.snow-dace.ts.net:8888";
            ca = ../../secrets/zrepl-persephone.snow-dace.ts.net.crt;
            cert = ../../secrets/zrepl-hestia.snow-dace.ts.net.crt;
            key = config.age.secrets."zrepl-hestia.snow-dace.ts.net.key".path;
            server_cn = "persephone.snow-dace.ts.net";
          };
          root_fs = "rpool/backup";
          interval = "10m";
          recv = {
            placeholder.encryption = "off";
            properties.override = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
          };
          pruning = {
            keep_sender = [
              {
                type = "regex";
                regex = "'.*'";
              }
            ];
            keep_receiver = [
              {
                type = "regex";
                negate = true;
                regex = "'^zrepl_'";
              }
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 12x30d";
                regex = "'^zrepl_'";
              }
            ];
          };
        }
      ];
    };
  };
}

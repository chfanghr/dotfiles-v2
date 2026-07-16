{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types toString;

  cfg = config.apollo.mountpoints.darwin-backups;

  root = "/data/darwin-backups";

  group = "darwin-backups";
  gid = 979;

  mpDirRule = {
    d = {
      group = toString gid;
      user = "root";
      mode = "0770";
    };
  };

  dioscuri = "dioscuri";
in {
  options.apollo.mountpoints.darwin-backups = {
    group = mkOption {
      type = types.str;
      default = group;
      readOnly = true;
    };

    ${dioscuri} = mkOption {
      type = types.path;
      default = "${root}/${dioscuri}";
      readOnly = true;
    };
  };

  config = {
    users = {
      users.fanghr.extraGroups = [group];
      groups.${group} = {inherit gid;};
    };

    systemd.tmpfiles.settings."40-darwin-backups" = {
      ${cfg.dioscuri} = mpDirRule;
    };

    services.samba.settings = {
      "tm-${dioscuri}" = {
        path = cfg.${dioscuri};
        "writeable" = "yes";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
}

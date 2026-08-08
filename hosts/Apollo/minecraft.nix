{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  user = "minecraft";
  group = "minecraft";
in {
  options.apollo.mountpoints.minecraft.main-smp = mkOption {
    type = types.str;
    default = "/data/minecraft/main-smp";
    readOnly = true;
  };

  config = {
    users = {
      users.${user} = {
        uid = 990;
        inherit group;
        isSystemUser = true;
      };
      groups.${group}.gid = 978;
    };

    systemd.tmpfiles.settings."40-minecraft" = {
      ${config.apollo.mountpoints.minecraft.main-smp}.d = {
        inherit user group;
        mode = "0770";
      };
    };
  };
}

{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  mp = config.apollo.mountpoints.yac;
in {
  options.apollo.mountpoints.yac = mkOption {
    type = types.path;
    default = "/data/comics";
  };

  config = {
    services.yac-reader-library = {
      enable = true;
      port = 8080;
      libs = [
        {
          name = "Comics - Manual";
          root = mp;
        }
        {
          name = "Comics - Weebcentral";
          root = "${mp}/dl";
        }
      ];
      settings.libraryConfig = {
        UPDATE_LIBRARIES_AT_STARTUP = true;
      };
      openFirewall = true;
    };

    users.users.fanghr.extraGroups = [config.services.yac-reader-library.group];
  };
}

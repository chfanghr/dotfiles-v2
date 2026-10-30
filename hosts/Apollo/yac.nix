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
    readOnly = true;
  };

  config = {
    services.yac-reader-library = {
      enable = true;
      package = config.dotfiles.shared.nixpkgs-unstable.pkgs.yacreader;
      port = 8080;
      libs = [
        {
          name = "Manual";
          root = "${mp}/manual";
        }
        {
          name = "Weebcentral";
          root = "${mp}/weebcentral";
        }
        {
          name = "Comix";
          root = "${mp}/comix";
        }
      ];
      settings.libraryConfig = {
        IMPORT_COMIC_INFO_XML_METADATA = true;
        UPDATE_LIBRARIES_AT_STARTUP = true;
      };
      openFirewall = true;
    };

    users.users.fanghr.extraGroups = [config.services.yac-reader-library.group];
  };
}

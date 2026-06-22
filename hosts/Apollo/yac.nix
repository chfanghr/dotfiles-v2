{config, ...}: let
  mp = config.disko.devices.zpool.dpool.datasets."enc/comics".mountpoint;
in {
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
}

{config, ...}: {
  services.yac-reader-library = {
    enable = true;
    port = 8080;
    libraryName = "Comics";
    libraryRoot = config.disko.devices.zpool.dpool.datasets."enc/comics".mountpoint;
    settings.libraryConfig = {
      UPDATE_LIBRARIES_AT_STARTUP = true;
    };
    openFirewall = true;
  };

  users.users.fanghr.extraGroups = [config.services.yac-reader-library.group];
}

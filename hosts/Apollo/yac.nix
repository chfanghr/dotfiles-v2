{config, ...}: {
  services.yac-reader-library = {
    enable = true;
    port = 8080;
    libraryName = "Comics";
    libraryRoot = config.disko.devices.zpool.dpool.datasets."enc/comics".mountpoint;
    settings.libraryConfig = {
      UPDATE_LIBRARIES_AT_STARTUP = true;
    };
    logLevel = "debug";
    openFirewall = true;
  };
}

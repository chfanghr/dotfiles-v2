{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.apollo.mountpoints.qbittorrent = mkOption {
    type = types.path;
    default = "/data/qbittorrent";
    readOnly = true;
  };

  config.dotfiles.nixos.containers.qbittorrent = {
    enable = true;
    # autoStart = false;
    altUIPackage = pkgs.fetchzip {
      url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.34.0/vuetorrent.zip";
      hash = "sha256-MtTN4O1sCF7JhSzz218qrF+zNZEII09AhLxG6fCPIOk=";
    };
    profileDir = config.apollo.mountpoints.qbittorrent;
    user.id = 42420;
    group.id = 42420;
    reverseProxy = {
      enable = true;
      authMiddleware = config.apollo.services.authelia.middleware;
    };
    p2p.hostBridge = config.apollo.networking.interfaces.containerBridge.name;
    monitoring = {
      hostAddress = "172.18.0.1";
      localAddress = "172.18.0.2";
    };
  };
}

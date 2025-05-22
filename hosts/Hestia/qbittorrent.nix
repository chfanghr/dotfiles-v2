{
  inputs,
  pkgs,
  config,
  ...
}: {
  hestia.containers.qbittorrent = {
    containerName = "qbt";

    qbtPackage = let
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv) system;
      };
    in
      pkgsUnstable.qbittorrent-nox;

    dataDir = "/data/qbittorrent";

    user = {
      name = "qbittorrent";
      id = 995;
    };
    group = {
      name = "qbittorrent";
      id = 992;
    };

    altUI = {
      package = pkgs.fetchzip {
        url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.18.0/vuetorrent.zip";
        hash = "sha256-Z+N1RgcF67R6hWEfmfBls1+YLWkhEJQuOVqXXJCyptE=";
      };
      mountPoint = "${config.hestia.containers.qbittorrent.dataDir}/alt_ui";
    };

    p2p = {
      veth = "ve-qbt-p2p";
      port = 28721;
      hostBridge = config.hestia.networking.server.lanBridge.interface;
    };

    monitoring = {
      veth = "ve-qbt-mon";
      hostAddress = "172.16.0.1";
      localAddress = "172.16.0.2";
      uiPort = 8080;
    };

    reverseProxyPrefix = "/qbittorrent";
  };
}

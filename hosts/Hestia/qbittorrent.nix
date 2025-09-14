{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  hestia.containers.qbittorrent = {
    containerName = "qbt";

    qbtPackage = pkgs.qbittorrent-nox;

    dataDir = mkDefault "/data/qbittorrent";

    user = {
      name = "qbittorrent";
      id = 995;
    };
    group = {
      name = "qbittorrent";
      id = 992;
    };

    p2p = {
      veth = "ve-qbt-p2p";
      port = 28721;
      hostBridge = config.hestia.networking.server.lanBridge.interface;
    };

    monitoring = {
      veth = "ve-qbt-mon";
      hostAddress = "172.17.0.1";
      localAddress = "172.17.0.2";
      ui = {
        port = 8080;
        passwordHash = "YsnDMfnpnTgcF0oRqLK/pQ==:OJmY+fOw/4Bl7RCSt+HAJEtX3H2oqq4TmV8NjiWQUI5I4JKMTO6JOU5e85RXtk0s3+uX2V7PCz/5zFslCOgspA==";
        altPackage = pkgs.fetchzip {
          url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.29.0/vuetorrent.zip";
          hash = "sha256-L0C17iT5S5Kdk8RRdUeWVYQu0ucch6zAyfyzc9Esa/c=";
        };
      };
    };

    reverseProxyPrefix = "/qbittorrent";

    categories = ["Misc" "Anime"];
  };
}

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    {
      hestia = {
        server.networking = {
          lanBridge = {
            interface = "br0";
            netdevProfile = "40-br0";
            networkProfile = "40-br0";
            slave = {
              interfaces = [
                "enp195s0"
                # config.hestia.server.networking.ap.interface
              ];
              networkProfile = "40-br0-slaves";
            };
            dummy = {
              interface = "dummy0";
              netdevProfile = "40-dummy0";
              networkProfile = "40-dummy0";
            };
          };
          ap = {
            device = "wlp194s0";
            ssid = "Hestia";
            encryptedPasswordFile = ../../../secrets/hestia-ap-password.age;
          };
        };
        containers.qbittorrent = {
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
            hostBridge = config.hestia.server.networking.lanBridge.interface;
          };

          monitoring = {
            veth = "ve-qbt-mon";
            hostAddress = "172.16.0.1";
            localAddress = "172.16.0.2";
            uiPort = 8080;
          };

          reverseProxyPrefix = "/qbittorrent";
        };
      };
    }

    (mkIf (config.hestia.mode == "server") {
      hestia = {
        containers.qbittorrent.enable = true;
        server.networking.enable = true;
      };
    })

    ./networking.nix
  ];
}

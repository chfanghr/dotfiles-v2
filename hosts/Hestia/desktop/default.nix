{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    {
      hestia.desktop.networking = {
        lanBridge = {
          interface = "br0";
          slave.interfaces = ["enp195s0"];
        };
      };
    }

    (mkIf (config.hestia.mode == "desktop") {
      dotfiles.shared.props.purposes.graphical = {
        gaming = true;
        desktop = true;
      };

      home-manager.users.fanghr = {
        home.packages = [
          pkgs.qbittorrent
        ];
      };
    })

    ./networking.nix
  ];
}

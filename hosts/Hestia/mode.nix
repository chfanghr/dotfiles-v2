{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption mkIf;
in {
  options.hestia.mode = mkOption {
    type = types.enum ["server" "desktop"];
    default = "server";
  };

  imports = [
    (mkIf (config.hestia.mode == "server") {
      hestia = {
        networking.server.enable = true;
        containers.qbittorrent.enable = true;
      };
    })
    (mkIf (config.hestia.mode == "desktop") {
      hestia.networking.desktop.enable = true;

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
  ];
}

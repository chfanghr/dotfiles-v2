{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
in
  mkIf (config.dotfiles.shared.props.purposes.graphical.desktop
    && !config.dotfiles.shared.props.hardware.steamdeck) {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session.command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu
        '';
      };
    };

    boot.plymouth.enable = mkDefault true;
  }

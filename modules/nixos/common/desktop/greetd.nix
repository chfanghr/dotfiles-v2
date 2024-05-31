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
      settings = {
        default_session.command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd hyprland
        '';
      };
    };

    environment.etc."greetd/environments".text = ''
      hyprland
    '';

    # this is a life saver.
    # literally no documentation about this anywhere.
    # might be good to write about this...
    # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    boot.plymouth.enable = mkDefault true;
  }

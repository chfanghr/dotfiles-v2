{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
in {
  options.demeter.greetd-sway.enable =
    mkEnableOption "spin up tuigreet and start sway on successful login"
    // {
      default = true;
    };

  config = mkIf config.demeter.greetd-sway.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session.command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd sway
        '';
      };
    };

    environment.etc."greetd/environments".text = ''
      sway
    '';
  };
}

{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in
  mkIf (config.dotfiles.hasProp "has-bluetooth") {
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    services.blueman.enable = config.dotfiles.hasProp "needs-blueman";
  }

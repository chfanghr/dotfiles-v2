{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in
  mkIf (config.dotfiles.hasProp "is-graphical")
  {
    home-manager.users.fanghr = {
      dotfiles.graphical.enable = true;
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    programs.dconf.enable = true;
  }

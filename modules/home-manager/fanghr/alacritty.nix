{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        option_as_alt = "OnlyLeft";
        blur = true;
        opacity = 0.7;
      };
      font = {
        normal.family = "CaskaydiaCoveNerdFontMono";
        size = 16;
      };
      keyboard.bindings = [
        {
          key = "=";
          mods = "Super";
          action = "IncreaseFontSize";
        }
        {
          key = "-";
          mods = "Super";
          action = "DecreaseFontSize";
        }
      ];
    };
  };

  home.packages = [
    pkgs.nerdfonts
  ];
}

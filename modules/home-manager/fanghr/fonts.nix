{
  lib,
  config,
  ...
}:
lib.mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
  fonts.fontconfig = {
    enable = true;
  };
}

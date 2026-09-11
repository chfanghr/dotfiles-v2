{
  config,
  lib,
  ...
}:
lib.mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };
}

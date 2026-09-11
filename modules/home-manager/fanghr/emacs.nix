{config, ...}: {
  programs.emacs.enable = !config.dotfiles.shared.props.purposes.lightweight;
}

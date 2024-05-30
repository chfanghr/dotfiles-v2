{
  lib,
  config,
  ...
}:
lib.mkIf config.dotfiles.shared.props.purposes.work {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}

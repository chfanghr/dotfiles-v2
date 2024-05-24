{
  lib,
  config,
  ...
}:
lib.mkIf (config.dotfiles.hasProp "is-for-work") {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}

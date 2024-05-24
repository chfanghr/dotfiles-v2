{
  lib,
  config,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.dotfiles.hasProp "is-for-gaming") {
    security.polkit.enable = true;
  })
]

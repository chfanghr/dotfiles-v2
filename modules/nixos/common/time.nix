{
  lib,
  config,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.dotfiles.hasProp "is-on-lan") {
    time.timeZone = "Asia/Hong_Kong";
  })
]

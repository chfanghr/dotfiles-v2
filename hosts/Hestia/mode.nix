{lib, ...}: let
  inherit (lib) types mkOption;
in {
  options.hestia.mode = mkOption {
    type = types.enum ["server" "desktop"];
    default = "server";
  };
}

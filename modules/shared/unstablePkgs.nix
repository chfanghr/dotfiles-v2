{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) types mkOption;
in {
  options.dotfiles.shared.nixpkgs-unstable = {
    config = mkOption {
      type = types.attrs;
      default = {};
    };
    pkgs = mkOption {
      type = types.unspecified;
      default = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = config.dotfiles.shared.nixpkgs-unstable.config;
      };
    };
  };
}

{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mdDoc mkIf;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };
in {
  options.dotfiles.nixos.props.hardware.rgb = mkPropOption "has rgb controllers";

  config = mkIf config.dotfiles.nixos.props.hardware.rgb {
    environment.systemPackages = [config.services.hardware.openrgb.package];
    services.hardware.openrgb.enable = true;
    hardware.i2c.enable = true;
  };
}

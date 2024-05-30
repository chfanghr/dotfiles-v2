{lib, ...}: let
  inherit (lib) mkOption types mdDoc;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Shared property: this machine ${name}";
    };
in {
  options.dotfiles.shared.props.hardware.steamdeck = mkPropOption "is a steamdeck";
}

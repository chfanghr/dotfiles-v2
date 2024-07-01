{lib, ...}: let
  inherit (lib) mkOption types mdDoc;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Shared property: this machine ${name}";
    };
in {
  options.dotfiles.shared.props = {
    purposes = {
      work = mkPropOption "used for work";
      graphical = {
        gaming = mkPropOption "runs games";
        desktop = mkPropOption "runs desktop graphical sessions";
      };
      vps = mkPropOption "runs in cloud";
    };
  };
}

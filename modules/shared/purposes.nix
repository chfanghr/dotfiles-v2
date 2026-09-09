{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mdDoc;
  inherit (config.dotfiles.shared.props) purposes;
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
      lightweight =
        (mkPropOption "disable heavy weighted stuff")
        // {
          default = purposes.vps || !(purposes.work || purposes.graphical.gaming || purposes.graphical.desktop);
        };
    };
  };
}

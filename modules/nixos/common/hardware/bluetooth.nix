{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mdDoc mkIf;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };
  bluetoothProps = config.dotfiles.nixos.props.hardware.bluetooth;
in {
  options.dotfiles.nixos.props.hardware.bluetooth = {
    enable = mkPropOption "has bluetooth adaptor";
    blueman = mkPropOption "uses blueman to manage bluetooth";
  };

  config = mkIf bluetoothProps.enable {
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
          UserspaceHID = true;
        };
      };
    };

    services.blueman.enable = bluetoothProps.blueman;
  };
}

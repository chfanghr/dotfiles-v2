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
in {
  options.dotfiles.nixos.props.ociHost = mkPropOption "runs oci containers";

  config = mkIf config.dotfiles.nixos.props.ociHost {
    virtualisation.podman = {
      enable = true;
      # networkSocket.enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {dns_enabled = true;};
    };
  };
}

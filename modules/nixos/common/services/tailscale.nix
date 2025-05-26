{
  config,
  inputs,
  pkgs,
  ...
}: let
  pkgs2411 = import inputs.nixpkgs-2411 {
    inherit (pkgs.stdenv) system;
  };
in {
  services.tailscale = {
    enable = true;
    package = pkgs2411.tailscale;
    useRoutingFeatures =
      if config.dotfiles.shared.props.purposes.vps
      then "server"
      else "client";
  };
}

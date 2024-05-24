{config, ...}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = let
      inherit (config.dotfiles) hasProp;
    in
      if hasProp "is-vps"
      then "server"
      else "client";
  };
}

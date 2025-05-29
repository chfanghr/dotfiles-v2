{config, ...}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures =
      if config.dotfiles.shared.props.purposes.vps
      then "server"
      else "client";
  };
}

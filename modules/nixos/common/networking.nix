{
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkIf mkMerge;
in
  mkMerge [
    {
      networking = {
        useDHCP = mkDefault true;
        useNetworkd = mkDefault true;
        enableIPv6 = mkDefault true;
        firewall.enable = mkDefault true;
      };
    }
    (
      mkIf (config.dotfiles.hasProp "use-router-proxy") {
        networking.proxy = {
          default = config.dotfiles.networking.routerProxy;
          httpProxy = config.dotfiles.networking.routerProxy;
          httpsProxy = config.dotfiles.networking.routerProxy;
        };
      }
    )
  ]

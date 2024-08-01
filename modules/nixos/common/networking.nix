{
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkIf mkMerge mkOption types;
in {
  options.dotfiles.nixos.networking.lanInterfaces = mkOption {
    type = types.listOf types.str;
    default = [];
  };
  config = mkMerge [
    {
      networking = {
        useDHCP = mkDefault true;
        useNetworkd = mkDefault true;
        enableIPv6 = mkDefault true;
        firewall.enable = mkDefault true;
      };
    }
    (
      mkIf config.dotfiles.shared.props.networking.home.proxy.useRouter {
        networking.proxy = let
          inherit (config.dotfiles.shared.networking.home) router;
          proxy = "http://${router.address}:${builtins.toString router.proxyPorts.http}";
        in {
          default = proxy;
          httpProxy = proxy;
          httpsProxy = proxy;
          noProxy = "127.0.0.1,localhost,*.local,*.snow-dace.ts.net";
        };
      }
    )
  ];
}

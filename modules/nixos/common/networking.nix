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
        nameservers = mkDefault [
          "1.1.1.1"
          "8.8.8.8"
          "9.9.9.9"
          "223.5.5.5"
          "114.114.114.114"
        ];
      };
    }
    (
      mkIf config.dotfiles.shared.props.networking.home.proxy.useGateway {
        networking.proxy = let
          inherit (config.dotfiles.shared.networking.home) gateway;
          proxy = "http://${gateway.address}:${builtins.toString gateway.proxyPorts.http}";
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

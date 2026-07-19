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
        nftables.enable = mkDefault true;
        nameservers = mkDefault [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    }
    (
      mkIf config.dotfiles.shared.props.networking.lan.ipv4.gfwBypass.useProxy {
        networking.proxy = let
          inherit (config.dotfiles.shared.props.location.networking.lan.ipv4.gfwBypass) proxy;
          proxy' = "http://${proxy.address}:${builtins.toString proxy.http.port}";
        in {
          default = proxy';
          httpProxy = proxy';
          httpsProxy = proxy';
          noProxy = "127.0.0.1,localhost,*.local,*.snow-dace.ts.net";
        };
      }
    )
  ];
}

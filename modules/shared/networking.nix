{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mdDoc;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Shared property: this machine ${name}";
    };

  inherit (config.dotfiles.shared) props;
in {
  options.dotfiles.shared = {
    props.networking.home = {
      proxy.useRouter = mkPropOption "needs to use the proxy server runs on the router";
      onLanNetwork = mkPropOption "is on subnet 10.42.0.0/16";
    };
    networking.home.router = {
      address = mkOption {
        type = types.str;
      };
      proxyPorts = {
        http = mkOption {
          type = types.port;
        };
        socks5 = mkOption {
          type = types.port;
        };
      };
    };
  };

  config.assertions = [
    {
      assertion = props.purposes.vps -> !props.networking.home.onLanNetwork;
      message = "VPS cannot be on home lan network";
    }
    {
      assertion = props.networking.home.proxy.useRouter -> props.networking.home.onLanNetwork;
      message = "To use the proxy service runs on the router, the machine should be on home lan";
    }
  ];
}

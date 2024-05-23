{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;
in {
  options.demeter.networking.mainPhyInterface = mkOption {
    type = types.str;
    default = "enp81s0";
    readOnly = true;
  };

  config = {
    networking = {
      useDHCP = true;
      networkmanager.enable = false;
      useNetworkd = true;
      enableIPv6 = true;
      proxy = {
        default = "http://10.42.0.1:1086";
        httpProxy = "http://10.42.0.1:1086";
        httpsProxy = "http://10.42.0.1:1086";
      };
      firewall = {
        enable = true;
      };
    };

    # systemd.network.wait-online.extraArgs = ["-i" config.demeter.networking.mainPhyInterface];

    services.iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };
}

{
  config,
  lib,
  ...
}: let
  cfg = config.services.tailscale-traefik;
in {
  options.services.tailscale-traefik = {
    enable = lib.mkEnableOption "traefik server with tailscale cert";

    hostName = lib.mkOption {
      type = lib.types.str;
    };

    tsDomainName = lib.mkOption {
      type = lib.types.str;
      default = "snow-dace.ts.net";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale-traefik.hostName = lib.mkDefault (lib.toLower config.networking.hostName);

    services.traefik = let
      fullDomainName = "${cfg.hostName}.${cfg.tsDomainName}";
    in {
      enable = true;
      staticConfigOptions = {
        global.sendAnonymousUsage = false;
        certificatesResolvers.tailnetResolver.tailscale = {};
        entryPoints = {
          insecure = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "secure";
              scheme = "https";
            };
          };
          secure = {
            address = ":443";
            http.tls = {
              certResolver = "tailnetResolver";
              domains = [{main = fullDomainName;}];
            };
          };
        };
      };
    };

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [80 443];

    systemd.services.traefik.bindsTo = ["tailscaled.service"];

    services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
  };
}

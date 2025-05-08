{config, ...}: {
  services.traefik = let
    domainName = "persephone.snow-dace.ts.net";
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
            domains = [{main = domainName;}];
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  systemd.services.traefik.wants = ["tailscaled.service"];

  services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
}

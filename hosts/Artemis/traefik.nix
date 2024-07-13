{config, ...}: {
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      global.sendAnonymousUsage = false;
      # accessLog = {};
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
            domains = [{main = "artemis.snow-dace.ts.net";}];
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          qbittorrent = {
            service = "qbittorrent";
            rule = "Host(`artemis.snow-dace.ts.net`)";
          };
        };
        services = {
          qbittorrent.loadBalancer.servers = [
            {url = "http://127.0.0.1:8080";}
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  systemd.services.traefik.wants = ["tailscaled.service"];

  services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
}

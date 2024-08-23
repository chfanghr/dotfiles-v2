{config, ...}: {
  services.traefik = let
    domainName = "persephone.snow-dace.ts.net";
    qbittorrentPrefix = "/qbittorrent";
  in {
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
            domains = [{main = domainName;}];
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          qbittorrent = {
            service = "qbittorrent";
            rule = "Host(`${domainName}`) && PathPrefix(`${qbittorrentPrefix}`)";
            middlewares = [
              "qbittorrentRedirect"
              "qbittorrentStripPrefix"
              "qbittorrentSetHeaders"
            ];
          };
        };
        middlewares = {
          qbittorrentSetHeaders.headers.customRequestHeaders = {
            X-Frame-Options = "SAMEORIGIN";
            Referer = "";
            Origin = "";
          };
          qbittorrentRedirect.redirectRegex = {
            regex = "^(.*)${qbittorrentPrefix}$";
            replacement = "$1${qbittorrentPrefix}/";
          };
          qbittorrentStripPrefix.stripPrefix.prefixes = ["${qbittorrentPrefix}/"];
        };
        services = {
          qbittorrent.loadBalancer = {
            passHostHeader = false;
            servers = [
              {
                url = "http://127.0.0.1:${builtins.toString config.services.qbittorrent.port}";
              }
            ];
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  systemd.services.traefik.wants = ["tailscaled.service"];

  services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
}

{config, ...}: {
  services.traefik = let
    domainName = "persephone.snow-dace.ts.net";
    qbittorrentPrefix = "/qbittorrent";
    jellyfinPrefix = "/jellyfin";
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
          jellyfin = {
            service = "jellyfin";
            rule = "Host(`${domainName}`) && PathPrefix(`${jellyfinPrefix}`)";
            # middlewares = [
            #   "jellyfinSetHeaders"
            # ];
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
          jellyfinSetHeaders.headers = {
            stsSeconds = 315360000;
            stsIncludeSubdomains = true;
            stsPreload = true;
            forceSTSHeader = true;
            frameDeny = true;
            contentTypeNosniff = true;
            # customresponseheaders.X-XSS-PROTECTION=1;
            # customFrameOptionsValue="allow-from https://snow-dace.ts.net";
          };
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
          jellyfin.loadBalancer = {
            passHostHeader = true;
            servers = [
              {
                url = "http://127.0.0.1:8096/";
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

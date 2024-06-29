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
            domains = [{main = "demeter.snow-dace.ts.net";}];
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          grafana = {
            service = "grafana";
            rule = "Host(`demeter.snow-dace.ts.net`) && PathPrefix(`/grafana/`)";
          };
          prometheusWriteReceiver = {
            service = "prometheusWriteReceiver";
            rule = "Host(`demeter.snow-dace.ts.net`) && Path(`/prometheus/write`)";
            middlewares = ["setPrometheusWriteApiPath"];
          };
        };
        middlewares = {
          setPrometheusWriteApiPath = {
            replacePath.path = "/api/v1/write";
          };
        };
        services = {
          grafana.loadBalancer.servers = [
            {url = with config.services.grafana.settings.server; "http://127.0.0.1:${builtins.toString http_port}/";}
          ];
          prometheusWriteReceiver.loadBalancer.servers = [
            {url = with config.services.prometheus; "http://127.0.0.1:${builtins.toString port}/";}
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  systemd.services.traefik.wants = ["tailscaled.service"];

  services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
}

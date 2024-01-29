{
  config,
  pkgs,
  lib,
  ...
}: let
  traefik3 = pkgs.buildGoModule rec {
    pname = "traefik";
    version = "3.0.0-beta5";
    src = pkgs.fetchzip {
      url = "https://github.com/traefik/traefik/releases/download/v${version}/traefik-v${version}.src.tar.gz";
      hash = "sha256-fEwwGF9r1ZdSDJoGDz3OD9ZOaiQfq2fupgO858flEeI=";
      stripRoot = false;
    };
    vendorHash = "sha256-Q6dlb6+mBRx8ZveFvFIXgAGHerzExi9HaSuJKVt1Ogc=";
    subPackages = ["cmd/traefik"];

    preBuild = ''
      go generate

      CODENAME=$(awk -F "=" '/CODENAME=/ { print $2}' script/binary)

      buildFlagsArray+=("-ldflags= -s -w \
        -X github.com/traefik/traefik/v${lib.versions.major version}/pkg/version.Version=${version} \
        -X github.com/traefik/traefik/v${lib.versions.major version}/pkg/version.Codename=$CODENAME")
    '';

    doCheck = false;
  };
in {
  services.traefik = {
    enable = true;
    package = traefik3;
    staticConfigOptions = {
      global.sendAnonymousUsage = false;
      accessLog = {};
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
        };
        services = {
          grafana.loadBalancer.servers = [
            {url = with config.services.grafana.settings.server; "http://127.0.0.1:${builtins.toString http_port}/";}
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  systemd.services.traefik.wants = ["tailscaled.service"];

  services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
}

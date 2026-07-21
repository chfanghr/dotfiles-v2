{
  config,
  lib,
  pkgs,
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

    fqdn = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.hostName}.${cfg.tsDomainName}";
      readOnly = true;
      description = "Computed fully-qualified domain name for the Traefik host.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale-traefik.hostName = lib.mkDefault (lib.toLower config.networking.hostName);

    services.traefik = {
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
              domains = [{main = cfg.fqdn;}];
            };
          };
        };
      };
    };

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [80 443];

    # tailscaled notifies systemd as soon as its local API socket is up, which
    # can be well before the node has logged in and connected to the tailnet.
    # Traefik must not start before that, or Tailscale certificate issuance
    # fails. This unit blocks until the tailnet connection is established.
    systemd.services = {
      tailscale-online = {
        description = "Wait for Tailscale to connect to the tailnet";
        after = ["tailscaled.service"];
        bindsTo = ["tailscaled.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "tailscale-online" ''
            until ${lib.getExe config.services.tailscale.package} status --json \
                | ${lib.getExe pkgs.jq} --exit-status '.BackendState == "Running"' > /dev/null; do
              ${pkgs.coreutils}/bin/sleep 1
            done
          '';
        };
      };

      traefik = {
        bindsTo = ["tailscaled.service"];
        after = ["tailscale-online.service"];
        requires = ["tailscale-online.service"];
      };
    };

    services.tailscale.permitCertUid = config.systemd.services.traefik.serviceConfig.User;
  };
}

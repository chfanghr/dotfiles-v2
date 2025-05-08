{config, ...}: {
  systemd.tmpfiles.settings."10-prometheus-data" = {
    "/data/prometheus".d = {
      user = "prometheus";
      group = "prometheus";
      mode = "0700";
    };

    "/var/lib/prometheus2".d = {
      user = "prometheus";
      group = "prometheus";
      mode = "0700";
    };
  };

  fileSystems = {
    "/data/prometheus" = {
      device = "tank/enc/prometheus";
      fsType = "zfs";
    };
    "/var/lib/prometheus2" = {
      device = "/data/prometheus";
      options = ["bind"];
    };
  };

  dotfiles.nixos.props.services.prometheus.pushToCollector = false;

  services = {
    prometheus = {
      enable = true;
      enableReload = true;
      listenAddress = "127.0.0.1";
      extraFlags = ["--web.enable-remote-write-receiver"];
      retentionTime = "1y";

      scrapeConfigs = [
        {
          job_name = "${config.networking.hostName}-node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
        {
          job_name = "${config.networking.hostName}-systemd";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
        {
          job_name = "${config.networking.hostName}-zfs";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
        {
          job_name = "${config.networking.hostName}-smartctl";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
              ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
      ];

      exporters = {
        node.enable = true;
        zfs.enable = true;
        smartctl.enable = true;
        systemd.enable = true;
      };
    };

    traefik.dynamicConfigOptions.http = {
      routers.prometheusWriteReceiver = {
        service = "prometheusWriteReceiver";
        rule = "Path(`/prometheus/write`)";
        middlewares = ["setPrometheusWriteApiPath"];
      };
      middlewares.setPrometheusWriteApiPath = {
        replacePath.path = "/api/v1/write";
      };
      services.prometheusWriteReceiver.loadBalancer.servers = [
        {url = with config.services.prometheus; "http://127.0.0.1:${builtins.toString port}/";}
      ];
    };
  };

  systemd.services.prometheus.bindsTo = ["data-prometheus.mount"];
}

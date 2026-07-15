{config, ...}: let
  hostName = config.networking.hostName;
in {
  environment.persistence.${config.apollo.mountpoints.persist}.directories = [
    {
      directory = "/var/lib/prometheus2";
      user = "prometheus";
      group = "prometheus";
      mode = "0700";
    }
  ];

  dotfiles.nixos.props.services.prometheus = {
    pushToCollector = false;
    enableDefault = true;
  };

  services = {
    prometheus = {
      listenAddress = "127.0.0.1";
      retentionTime = "1y";

      scrapeConfigs = [
        {
          job_name = "${hostName}-zfs";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}"
              ];
              labels.instance = hostName;
            }
          ];
        }
      ];

      exporters.zfs.enable = true;
    };

    grafana.provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        type = "prometheus";
      }
    ];
  };
}

{config, ...}: let
  hostName = config.networking.hostName;
  influxPort = 8086;
  zfsDatabase = "zfs";
in {
  environment.persistence.${config.apollo.mountpoints.persist}.directories = [
    {
      directory = config.services.influxdb.dataDir;
      user = config.services.influxdb.user;
      group = config.services.influxdb.group;
      mode = "0700";
    }
  ];

  services = {
    influxdb = {
      enable = true;
      settings.http.bind-address = "127.0.0.1:${toString influxPort}";
    };

    telegraf = {
      enable = true;
      extraConfig = {
        outputs.influxdb = {
          urls = ["http://127.0.0.1:${toString influxPort}"];
          database = zfsDatabase;
        };

        inputs.exec = {
          commands = [
            "${config.boot.zfs.package}/libexec/zfs/zpool_influxdb -t host=${hostName}"
          ];
          data_format = "influx";
        };
      };
    };

    grafana.provision.datasources.settings.datasources = [
      {
        name = "InfluxDB ZFS";
        url = "http://127.0.0.1:${toString influxPort}";
        type = "influxdb";
        database = zfsDatabase;
      }
    ];
  };

  systemd.services.telegraf = {
    after = ["influxdb.service"];
    requires = ["influxdb.service"];
  };
}

{config, ...}: {
  systemd.tmpfiles.settings."10-loki-data" = {
    "/data/loki".d = {
      user = config.services.loki.user;
      group = config.services.loki.group;
      mode = "0700";
    };

    ${config.services.loki.dataDir}.d = {
      user = config.services.loki.user;
      group = config.services.loki.group;
      mode = "0700";
    };
  };

  fileSystems = {
    "/data/loki" = {
      device = "tank/enc/loki";
      fsType = "zfs";
    };
    ${config.services.loki.dataDir} = {
      device = "/data/loki";
      options = ["bind"];
    };
  };

  services = {
    loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3100;
        auth_enabled = false;

        common = {
          path_prefix = config.services.loki.dataDir;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
        };

        schema_config.configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        storage_config.filesystem.directory = "${config.services.loki.dataDir}/chunks";
      };
    };

    grafana.provision.datasources.settings.datasources = [
      {
        name = "Loki";
        url = "http://127.0.0.1:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
        type = "loki";
      }
    ];
  };

  systemd.services.loki.bindsTo = ["data-loki.mount"];
}

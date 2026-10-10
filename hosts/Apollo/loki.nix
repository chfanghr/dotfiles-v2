{config, ...}: let
  inherit (builtins) toString;

  lokiAddr = "127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
in {
  environment.persistence.${config.apollo.mountpoints.persist}.directories = [
    {
      directory = config.services.loki.dataDir;
      user = config.services.loki.user;
      group = config.services.loki.group;
      mode = "0700";
    }
  ];

  services = {
    loki = {
      enable = true;

      configuration = {
        auth_enabled = false;
        server = {
          http_listen_port = 3100;
          grpc_listen_port = 9096;
        };

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = config.services.loki.dataDir;
        };

        query_range.results_cache.cache.embedded_cache = {
          enabled = true;
          max_size_mb = 512;
        };

        limits_config.metric_aggregation_enabled = true;

        schema_config.configs = [
          {
            from = "2026-10-09";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        pattern_ingester = {
          enabled = true;
          metric_aggregation.loki_address = lokiAddr;
        };
      };
    };

    grafana.provision.datasources.settings.datasources = [
      {
        name = "Loki";
        url = "http://${lokiAddr}";
        type = "loki";
      }
    ];
  };
}

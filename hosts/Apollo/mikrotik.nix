{config, ...}: {
  services.prometheus = {
    exporters.mktxp = {
      enable = true;
      defaultConfig = {};
      routerConfigs = {};
      exporterConfig = {
        listen = "127.0.0.1:49090";
      };
    };
    scrapeConfigs = [
      {
        job_name = "sg-mikrotik";
        static_configs = [
          {
            targets = [config.services.prometheus.exporters.mktxp.exporterConfig.listen];
          }
        ];
      }
    ];
  };
}

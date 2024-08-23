{config, ...}: {
  services.prometheus = {
    scrapeConfigs = [
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
      zfs.enable = true;
      smartctl.enable = true;
    };
  };
}

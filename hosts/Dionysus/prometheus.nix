{config, ...}: let
  hostName = config.networking.hostName;
in {
  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "${hostName}-nvidia";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.nvidia-gpu.port}"
            ];
            labels.instance = hostName;
          }
        ];
      }
    ];

    exporters.nvidia-gpu.enable = true;
  };
}

{config, ...}: {
  services.prometheus = {
    enable = true;
    enableReload = true;
    enableAgentMode = true;

    listenAddress = "127.0.0.1";

    scrapeConfigs = [
      {
        job_name = "uranus-node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];

    remoteWrite = [
      {
        name = "demeter";
        url = "https://demeter.snow-dace.ts.net/prometheus/write";
      }
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        listenAddress = "127.0.0.1";
      };
    };
  };
}

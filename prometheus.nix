{config, ...}: {
  services.prometheus = {
    enable = true;
    enableReload = true;
    listenAddress = "127.0.0.1";

    scrapeConfigs = [
      {
        job_name = "demeter-node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];

    extraFlags = [ "--web.enable-remote-write-receiver" ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        listenAddress = "127.0.0.1";
      };
    };
  };
}

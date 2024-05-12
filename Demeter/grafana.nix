{config, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "demeter.snow-dace.ts.net";
        root_url = "https://demeter.snow-dace.ts.net/grafana/";
        serve_from_sub_path = true;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          url = with config.services.prometheus; "http://127.0.0.1:${builtins.toString port}";
          type = "prometheus";
        }
      ];
    };
  };
}

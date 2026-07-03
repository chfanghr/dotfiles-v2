{config, ...}: {
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = "persephone.snow-dace.ts.net";
          root_url = "https://persephone.snow-dace.ts.net/grafana/";
          serve_from_sub_path = true;
        };
        # FIXME: bad shit, replace this with a age encrypted file
        security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
      };
      provision.enable = true;
    };

    traefik.dynamicConfigOptions.http = {
      routers.grafana = {
        service = "grafana";
        rule = "PathPrefix(`/grafana/`)";
      };
      services. grafana.loadBalancer.servers = [
        {url = with config.services.grafana.settings.server; "http://127.0.0.1:${builtins.toString http_port}/";}
      ];
    };
  };
}

{
  services = {
    tailscale-traefik.enable = true;

    # authelia.instances.main = {
    #   enable = true;
    # };

    traefik = {
      staticConfigOptions = {
        log.level = "DEBUG";
        api = {};
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            dashboard = {
              rule = "PathPrefix(`/api`) || PathPrefix(`/dashboard`)";
              service = "api@internal";
            };
          };
        };
      };
    };
  };
}

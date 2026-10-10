# TODO: move this to modules/nixos/common
{config, ...}: {
  services.vector = {
    enable = true;
    # adds the systemd-journal supplementary group to the unit
    journaldAccess = true;
    settings = {
      sources.journald = {
        type = "journald";
        # Loki rejects samples older than 168h, and there is no pre-existing
        # history in Loki to preserve, so start from now rather than
        # backfilling the whole journal on first start.
        since_now = true;
        current_boot_only = false;
      };

      sources.internal_metrics.type = "internal_metrics";

      # endpoint is a base URL; the sink appends its `path`, which defaults
      # to /loki/api/v1/push
      sinks.loki = {
        type = "loki";
        inputs = ["journald"];
        endpoint = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
        encoding.codec = "text";
        labels = {
          job = "systemd-journal";
          host = config.networking.hostName;
          unit = "{{ _SYSTEMD_UNIT }}";
        };
      };
    };
  };
}

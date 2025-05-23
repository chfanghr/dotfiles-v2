let
  artemisHostname = "Artemis";
  artemisFQDN = "artemis.barbel-tritone.ts.net";

  artemisNodeExporterPort = 9100;
  artemisSystemdExporterPort = 9558;
  artemisSmartctlExporterPort = 9633;
  artemisZfsExporterPort = 9134;
in {
  services.prometheus.scrapeConfigs = [
    {
      job_name = "${artemisHostname}-node";
      static_configs = [
        {
          targets = [
            "${artemisFQDN}:${toString artemisNodeExporterPort}"
          ];
          labels.instance = artemisHostname;
        }
      ];
    }
    {
      job_name = "${artemisHostname}-systemd";
      static_configs = [
        {
          targets = [
            "${artemisFQDN}:${toString artemisSystemdExporterPort}"
          ];
          labels.instance = artemisHostname;
        }
      ];
    }
    {
      job_name = "${artemisHostname}-zfs";
      static_configs = [
        {
          targets = [
            "${artemisFQDN}:${toString artemisZfsExporterPort}"
          ];
          labels.instance = artemisHostname;
        }
      ];
    }
    {
      job_name = "${artemisHostname}-smartctl";
      static_configs = [
        {
          targets = [
            "${artemisFQDN}:${toString artemisSmartctlExporterPort}"
          ];
          labels.instance = artemisHostname;
        }
      ];
    }
  ];
}

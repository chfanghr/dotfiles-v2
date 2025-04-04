{config, ...}: {
  security.krb5 = {
    enable = true;
    settings = {
      libdefaults.default_realm = "SNOW-DACE.TS.NET";
      realms."SNOW-DACE.TS.NET" = {
        kdc = ["persephone.snow-dace.ts.net"];
        admin_server = "persephone.snow-dace.ts.net";
        default_principal_flags = "+preauth";
      };
      domain_realm = {
        "snow-dace.ts.net" = "SNOW-DACE.TS.NET";
        ".snow-dace.ts.net" = "SNOW-DACE.TS.NET";
      };
    };
  };

  services.kerberos_server = {
    enable = true;
    settings = {
      kdcdefaults = {
        kdc_listen = 88;
        kdc_tcp_listen = 88;
      };
      realms = {
        "SNOW-DACE.TS.NET" = {
          kadmind_port = 749;
          max_life = "12h 0m 0s";
          max_renewable_life = "7d 0h 0m 0s";
          master_key_type = "aes256-cts";
          supported_enctypes = "aes256-cts:normal aes128-cts:normal";
        };
      };
    };
  };

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [
      config.services.kerberos_server.settings.kdcdefaults.kdc_tcp_listen
      config.services.kerberos_server.settings.realms."SNOW-DACE.TS.NET".kadmind_port
    ];
    allowedUDPPorts = [config.services.kerberos_server.settings.kdcdefaults.kdc_listen];
  };
}

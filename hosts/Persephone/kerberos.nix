{config, ...}: let
  stateDir = "/data/kerberos-server-state";
in {
  age.secrets = {
    default-keytab = {
      owner = "root";
      file = ../../secrets/persephone-default.keytab.age;
      path = "/etc/krb5.keytab";
      mode = "600";
    };
  };

  systemd.tmpfiles.settings."10-kerberos-server-state" = {
    ${stateDir}.d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
    "/var/lib/krb5kdc".d = {
      user = "root";
      group = "root";
      mode = "0600";
    };
  };

  fileSystems = {
    ${stateDir} = {
      device = "tank/enc/kerberos-server-state";
      fsType = "zfs";
      options = ["noatime" "noexec"];
    };
    "/var/lib/krb5kdc" = {
      device = stateDir;
      options = ["bind"];
    };
  };

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

  systemd.services.kdc = {
    bindsTo = [
      "data-kerberos\\x2dserver\\x2dstate.mount"
      "var-lib-krb5kdc.mount"
    ];
  };

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [
      config.services.kerberos_server.settings.kdcdefaults.kdc_tcp_listen
      config.services.kerberos_server.settings.realms."SNOW-DACE.TS.NET".kadmind_port
    ];
    allowedUDPPorts = [config.services.kerberos_server.settings.kdcdefaults.kdc_listen];
  };
}

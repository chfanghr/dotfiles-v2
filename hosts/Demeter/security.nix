{
  pkgs,
  config,
  ...
}: {
  security = {
    polkit.enable = true;

    krb5 = {
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
  };

  age.secrets = {
    default-keytab = {
      owner = "root";
      file = ../../secrets/demeter-default.keytab.age;
      path = "/etc/krb5.keytab";
      mode = "600";
    };
    minecraft-keytab = {
      owner = "root";
      file = ../../secrets/minecraft.keytab.age;
      mode = "600";
    };
  };

  systemd.services.minecraft-krb5-ticket-refresher = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    path = [
      pkgs.kstart
    ];
    script = ''
      k5start -U -f ${config.age.secrets.minecraft-keytab.path} \
        -k /srv/minecraft/krb-ticket-cache -l 10h -K 30 \
        -m 600 -o minecraft -g minecraft
    '';
    serviceConfig = {
      Restart = "on-failure";
    };
  };
}

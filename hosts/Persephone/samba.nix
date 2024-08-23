{
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];

  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server role = standalone server
      server min protocol = SMB2_02
      protocol=SMB3

      hosts allow = 10.41.0. 127.0.0.1 100. persephone.snow-dace.ts.net
      hosts deny = 0.0.0.0/0

      hide unreadable = yes

      guest account = nobody
      map to guest = bad user
      usershare allow guests = no

      log file = /var/log/samba/client.%I
      log level = 2

      create mask = 0664
      force create mode = 0664
      directory mask = 0775
      force directory mode = 0775
      follow symlinks = yes
      vfs objects = acl_xattr catia fruit streams_xattr
      inherit permissions = yes

      wins support = yes
      dns proxy = yes
    '';
    shares = {
      global = {
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
      qbittorrent = {
        path = "/data/qbittorrent/downloads";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
    };
  };
}

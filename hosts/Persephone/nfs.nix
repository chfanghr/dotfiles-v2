{config, ...}: {
  systemd.tmpfiles.settings."10-export" = {
    "/export".d = {
      user = "nobody";
      group = "nogroup";
    };
  };

  fileSystems."/export/minecraft/main" = {
    device = "/data/minecraft/main";
    options = ["bind"];
  };

  users.users.minecraft-data = {
    isSystemUser = true;
    group = "nogroup";
  };

  services.nfs = {
    server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /export 100.64.0.0/10(nohide,no_subtree_check,insecure,crossmnt,fsid=0)
        /export/minecraft/main 100.84.48.102(rw,nohide,insecure,no_subtree_check)
      '';
    };
    settings = {
      nfsd = {
        threads = 32;
        vers3 = false;
        vers4 = true;
        "vers4.1" = true;
        "vers4.2" = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      111
      2049
      config.services.nfs.server.lockdPort
      config.services.nfs.server.mountdPort
      config.services.nfs.server.statdPort
      20048
    ];
    allowedUDPPorts = [
      111
      2049
      config.services.nfs.server.lockdPort
      config.services.nfs.server.mountdPort
      config.services.nfs.server.statdPort
      20048
    ];
  };
}

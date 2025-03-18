{
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

  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /export 10.41.0.0/16(nohide,no_subtree_check,insecure,crossmnt,fsid=0)
      /export/minecraft/main  10.41.0.230(rw,nohide,insecure,no_subtree_check)
    '';
    extraNfsdConfig = ''
      threads=32
      vers3=on
      vers4=on
      vers4.1=on
    '';
  };
  networking.firewall = {
    allowedTCPPorts = [111 2049 4000 4001 4002 20048];
    allowedUDPPorts = [111 2049 4000 4001 4002 20048];
  };
}

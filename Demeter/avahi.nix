{
  pkgs,
  config,
  ...
}: {
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      workstation = true;
      hinfo = true;
      domain = true;
      addresses = true;
    };
    ipv6 = true;
    extraServiceFiles = {
      ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      sftp = "${pkgs.avahi}/etc/avahi/services/sftp-ssh.service";
    };
    allowInterfaces = [
      config.demeter.networking.mainPhyInterface
    ];
  };
}

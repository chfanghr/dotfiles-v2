{config, ...}: let
  calibreLibrary = "/data/calibre";
in {
  systemd.tmpfiles.settings."10-calibre".${calibreLibrary}.d = {
    user = config.services.calibre-web.user;
    group = config.services.calibre-web.group;
    mode = "0775";
  };

  fileSystems.${calibreLibrary} = {
    device = "vault/calibre";
    fsType = "zfs";
    options = ["noexec"];
  };

  services = {
    calibre-web = {
      enable = true;
      options = {
        inherit calibreLibrary;
        enableBookUploading = true;
        enableBookConversion = true;
        enableKepubify = true;
      };
      openFirewall = true;
    };
  };

  systemd.services.calibre-web.after = [
    "data-calibre.mount"
  ];
}

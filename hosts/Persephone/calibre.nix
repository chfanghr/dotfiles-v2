{config, ...}: let
  calibreLibrary = "/data/calibre";

  calibrePrefix = "/calibre";
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
      listen.ip = "127.0.0.1";
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

  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        calibre = {
          service = "calibre";
          rule = "PathPrefix(`${calibrePrefix}`)";
          middlewares = [
            "calibreRedirect"
            "calibreStripPrefix"
            "calibreSetHeaders"
          ];
        };
      };
      middlewares = {
        calibreSetHeaders.headers.customRequestHeaders = {
          X-Script-Name = calibrePrefix;
        };
        calibreRedirect.redirectRegex = {
          regex = "^(.*)${calibrePrefix}$";
          replacement = "$1${calibrePrefix}/";
        };
        calibreStripPrefix.stripPrefix.prefixes = ["${calibrePrefix}/"];
      };
      services = {
        calibre.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${builtins.toString config.services.calibre-web.listen.port}";
            }
          ];
        };
      };
    };
  };
}

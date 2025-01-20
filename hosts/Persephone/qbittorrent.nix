{
  config,
  pkgs,
  inputs,
  ...
}: let
  dataDir = "/data/qbittorrent";

  altUI = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.18.0/vuetorrent.zip";
    hash = "sha256-Z+N1RgcF67R6hWEfmfBls1+YLWkhEJQuOVqXXJCyptE=";
  };

  altUIPath = "${dataDir}/alt_ui";

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
  };
in {
  systemd.tmpfiles.settings."10-qbittorrent-data".${dataDir}.d = {
    inherit (config.services.qbittorrent) user group;
    mode = "0775";
  };

  fileSystems.${dataDir} = {
    device = "tank/enc/qbittorrent";
    fsType = "zfs";
    options = ["noatime" "noexec"];
  };

  services.qbittorrent = {
    enable = true;
    package = pkgsUnstable.qbittorrent-nox;
    inherit dataDir;
    openFilesLimit = 65536;
    port = 8080;
    openFirewall = false;
  };

  systemd.services = {
    ${config.services.qbittorrent.systemdServiceName}.after = [
      "data-qbittorrent.mount"
    ];
    qbittorrent-alt-ui = {
      wantedBy = ["multi-user.target"];
      before = ["${config.services.qbittorrent.systemdServiceName}.service"];
      serviceConfig = {
        inherit (config.systemd.services.${config.services.qbittorrent.systemdServiceName}.serviceConfig) User Group;
        Type = "oneshot";
        Restart = "no";
      };
      script = ''
        if [ -L ${altUIPath} ]; then
          unlink ${altUIPath}
        fi

        ln -s ${altUI} ${altUIPath}
      '';
    };
  };

  services.samba.settings = {
    qbittorrent = {
      path = "${dataDir}/downloads";
    };
    qbittorrent_incomplete = {
      path = "${dataDir}/incomplete";
      browsable = "no";
    };
  };
}

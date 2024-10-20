{
  config,
  pkgs,
  inputs,
  ...
}: let
  dataDir = "/data/qbittorrent";

  altUI = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.14.1/vuetorrent.zip";
    hash = "sha256-pSXhRxhjB21Us/OgvbIXKhZtpXWZD+F1yb6/w/PQASs=";
  };

  altUIPath = "${dataDir}/alt_ui";

  pkgs2405 = import inputs.nixpkgs-2405 {
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
    package = pkgs2405.qbittorrent-nox;
    enable = true;
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

  services.samba.settings.qbittorrent = {
    path = "${dataDir}/downloads";
  };
}

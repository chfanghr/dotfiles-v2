{
  config,
  pkgs,
  ...
}: let
  dataDir = "/data/qbittorrent";

  altUI = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.11.1/vuetorrent.zip";
    hash = "sha256-VoG4voG+ptYSNfrQhg5zKDnfxS86/n1XfZJTYocs6NA=";
  };

  altUIPath = "${dataDir}/alt_ui";
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
}

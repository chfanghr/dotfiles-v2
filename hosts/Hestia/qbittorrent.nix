{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  dataDir = "/mnt/qbittorrent";

  qbtUser = "qbittorrent";
  qbtGroup = "qbittorrent";
  qbtUid = 995;
  qbtGid = 992;

  altUI = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.18.0/vuetorrent.zip";
    hash = "sha256-Z+N1RgcF67R6hWEfmfBls1+YLWkhEJQuOVqXXJCyptE=";
  };

  altUIPath = "${dataDir}/alt_ui";

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
  };

  webServiceVeth = "ve-qbt";
  webUIPort = 8080;

  hostAddress = "172.16.0.1";
  localAddress = "172.16.0.2";

  containerName = "qbt";

  qbittorrentPrefix = "/qbittorrent";
in {
  users = {
    users.${qbtUser} = {
      uid = qbtUid;
      group = qbtGroup;
      isSystemUser = true;
    };

    groups.${qbtGroup}.gid = qbtGid;
  };

  services.samba.settings.qbittorrent.path = "${dataDir}/downloads";

  systemd.tmpfiles.settings."10-qbittorrent-data".${dataDir}.d = {
    user = qbtUser;
    group = qbtGroup;
    mode = "0775";
  };

  systemd.services."container@${containerName}".after = [
    "mnt-qbittorrent.mount"
  ];

  containers.${containerName} = {
    autoStart = true;
    ephemeral = true;

    bindMounts.qbt-data = {
      hostPath = dataDir;
      mountPoint = dataDir;
      isReadOnly = false;
    };

    privateNetwork = true;
    macvlans = ["enp195s0"];
    extraVeths.${webServiceVeth} = {
      inherit hostAddress localAddress;
    };

    config = {config, ...}: {
      imports = [../../modules/nixos/common/services/qbittorrent.nix];

      networking = {
        enableIPv6 = true;
        useNetworkd = true;
        interfaces."mv-enp195s0".useDHCP = true;
        useHostResolvConf = lib.mkForce false;
        firewall = {
          enable = true;
          interfaces.${webServiceVeth}.allowedTCPPorts = [
            webUIPort
            config.services.prometheus.exporters.node.port
          ];
        };
      };

      systemd = {
        services = {
          qbittorrent-alt-ui = {
            wantedBy = ["multi-user.target"];
            before = ["${config.services.qbittorrent.systemdServiceName}.service"];
            serviceConfig = {
              User = qbtUser;
              Group = qbtGroup;
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

        network = {
          wait-online.anyInterface = true;
          networks."40-mv-enp195s0".networkConfig.IPv6AcceptRA = true;
        };
      };

      services = {
        resolved.enable = true;

        qbittorrent = {
          enable = true;
          user = qbtUser;
          group = qbtGroup;
          package = pkgsUnstable.qbittorrent-nox;
          inherit dataDir;
          openFilesLimit = 65536;
          port = webUIPort;
          openFirewall = false;
          confirmLegalNotice = true;
        };

        prometheus.exporters.node = {
          enable = true;
          listenAddress = localAddress;
        };
      };

      users.users.${qbtUser} = {
        uid = qbtUid;
        group = qbtGroup;
      };
      users.groups.${qbtGroup}.gid = qbtGid;

      time.timeZone = "Asia/Hong_Kong";

      system.stateVersion = "24.11";
    };
  };

  services = {
    traefik.dynamicConfigOptions = {
      http = {
        routers = {
          qbittorrent = {
            service = "qbittorrent";
            rule = "PathPrefix(`${qbittorrentPrefix}`)";
            middlewares = [
              "qbittorrentRedirect"
              "qbittorrentStripPrefix"
              "qbittorrentSetHeaders"
            ];
          };
        };
        middlewares = {
          qbittorrentSetHeaders.headers.customRequestHeaders = {
            X-Frame-Options = "SAMEORIGIN";
            Referer = "";
            Origin = "";
          };
          qbittorrentRedirect.redirectRegex = {
            regex = "^(.*)${qbittorrentPrefix}$";
            replacement = "$1${qbittorrentPrefix}/";
          };
          qbittorrentStripPrefix.stripPrefix.prefixes = ["${qbittorrentPrefix}/"];
        };
        services = {
          qbittorrent.loadBalancer = {
            passHostHeader = false;
            servers = [
              {
                url = "http://${localAddress}:${builtins.toString webUIPort}";
              }
            ];
          };
        };
      };
    };
    prometheus.scrapeConfigs = [
      {
        job_name = "${config.networking.hostName}-qbt-node";
        static_configs = [
          {
            targets = [
              "${localAddress}:${toString config.containers.${containerName}.config.services.prometheus.exporters.node.port}"
            ];
            labels.instance = "${config.networking.hostName}-qbt";
          }
        ];
      }
    ];
  };
}

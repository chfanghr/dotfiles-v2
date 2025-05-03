{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: let
  dataDir = "/data/qbittorrent";

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

  p2pNic = "enp33s0f0";
  webServiceVeth = "ve-qbt";

  webUIPort = 8080;

  hostAddress = "172.16.0.1";
  localAddress = "172.16.0.2";

  containerName = "qbt";

  routerAddress = config.dotfiles.shared.networking.home.router.address;

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

  systemd.tmpfiles.settings."10-qbittorrent-data".${dataDir}.d = {
    user = qbtUser;
    group = qbtGroup;
    mode = "0775";
  };

  fileSystems.${dataDir} = {
    device = "tank/enc/qbittorrent";
    fsType = "zfs";
    options = ["noatime" "noexec"];
  };

  systemd.services."container@${containerName}".after = [
    "data-qbittorrent.mount"
  ];

  services.samba.settings = {
    qbittorrent = {
      path = "${dataDir}/downloads";
    };
    qbittorrent_incomplete = {
      path = "${dataDir}/incomplete";
      browsable = "no";
    };
  };

  containers.${containerName} = {
    ephemeral = true;
    privateNetwork = true;
    bindMounts.qbt-data = {
      hostPath = dataDir;
      mountPoint = dataDir;
      isReadOnly = false;
    };
    extraVeths.${webServiceVeth} = {
      inherit hostAddress localAddress;
    };
    # NOTE(chfanghr): When stuck on "no such device", run `sudo lsns --type=net`
    # and kill the nsenter process.
    interfaces = [p2pNic];
    autoStart = true;

    config = {config, ...}: {
      imports = [../../modules/nixos/common/services/qbittorrent.nix];

      networking = {
        enableIPv6 = true;
        interfaces.${p2pNic} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.41.0.173";
              prefixLength = 16;
            }
          ];
        };
        defaultGateway = {
          address = routerAddress;
          interface = p2pNic;
        };
        useNetworkd = true;
        firewall = {
          enable = true;
          interfaces.${webServiceVeth}.allowedTCPPorts = [webUIPort];
        };
        useHostResolvConf = lib.mkForce false;
        nameservers = [
          "1.1.1.1"
          routerAddress
        ];
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
      };

      users.users.${qbtUser} = {
        uid = qbtUid;
        group = qbtGroup;
      };
      users.groups.${qbtGroup}.gid = qbtGid;

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
          wait-online.ignoredInterfaces = [p2pNic];
          networks."40-${p2pNic}".networkConfig.IPv6AcceptRA = true;
        };
      };

      time.timeZone = "Asia/Hong_Kong";

      system.stateVersion = "24.11";
    };
  };

  services.traefik.dynamicConfigOptions = {
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
}

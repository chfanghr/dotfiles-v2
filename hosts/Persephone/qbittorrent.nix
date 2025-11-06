{
  lib,
  pkgs,
  config,
  ...
}: let
  dataDir = "/data/qbittorrent";

  qbtUser = "qbittorrent";
  qbtGroup = "qbittorrent";
  qbtUid = 995;
  qbtGid = 992;

  altUI = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.30.2/vuetorrent.zip";
    hash = "sha256-PFmqonv1Q71yc6cVVqXzw7Br4TVazB36qXtEY3SeBuQ=";
  };

  altUIPath = "${dataDir}/alt_ui";

  p2pNic = "ens1f0";
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
    interfaces = ["enp33s0f0"];
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
          interfaces.${webServiceVeth}.allowedTCPPorts = [
            webUIPort
            config.services.prometheus.exporters.node.port
          ];
        };
        useHostResolvConf = lib.mkForce false;
        nameservers = lib.mkForce [
          routerAddress
        ];
      };

      services = {
        resolved.enable = true;

        qbittorrent-custom = {
          enable = true;
          user = qbtUser;
          group = qbtGroup;
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

      systemd = {
        services = {
          qbittorrent-alt-ui = {
            wantedBy = ["multi-user.target"];
            before = ["${config.services.qbittorrent-custom.systemdServiceName}.service"];
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
          networks = {
            "40-${p2pNic}".networkConfig.IPv6AcceptRA = true;
            "40-${webServiceVeth}" = {
              matchConfig.Name = webServiceVeth;
              linkConfig.Unmanaged = true;
            };
          };
        };
      };

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

  systemd.services."container@${containerName}" = {
    after = [
      "data-qbittorrent.mount"
    ];
    postStart = ''
      # Don't let tailscale hijack the traffic
      ip route add throw 172.16.0.0/28 table 52
    '';
    preStop = ''
      ip route delete throw 172.16.0.0/28 table 52 || true
    '';
  };
}

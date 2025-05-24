{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption mkIf mkForce mkEnableOption;
  cfg = config.hestia.containers.qbittorrent;
in {
  options.hestia.containers.qbittorrent = {
    enable = mkEnableOption "qbittorrent container";

    containerName = mkOption {type = types.str;};

    qbtPackage = mkOption {type = types.package;};

    dataDir = mkOption {type = types.path;};

    user = {
      name = mkOption {type = types.str;};
      id = mkOption {type = types.int;};
    };
    group = {
      name = mkOption {type = types.str;};
      id = mkOption {type = types.int;};
    };

    altUI = {
      package = mkOption {type = types.package;};
      mountPoint = mkOption {type = types.path;};
    };

    p2p = {
      veth = mkOption {type = types.str;};
      port = mkOption {type = types.port;};
      hostBridge = mkOption {type = types.str;};
    };

    monitoring = {
      veth = mkOption {type = types.str;};
      hostAddress = mkOption {type = types.str;};
      localAddress = mkOption {type = types.str;};
      uiPort = mkOption {type = types.port;};
    };

    reverseProxyPrefix = mkOption {type = types.str;};
  };
  imports = [
    {
      users = {
        users.${cfg.user.name} = {
          uid = cfg.user.id;
          group = cfg.group.name;
          isSystemUser = true;
        };
        groups.${cfg.group.name}.gid = cfg.group.id;
      };

      services.samba.settings.qbittorrent.path = "${cfg.dataDir}/downloads";

      systemd.tmpfiles.settings."10-qbittorrent-data".${cfg.dataDir}.d = {
        user = cfg.user.name;
        group = cfg.group.name;
        mode = "0775";
      };
    }
    (mkIf cfg.enable {
      # HACK
      systemd.services."container@${cfg.containerName}".bindsTo = [
        "data-qbittorrent.mount"
      ];

      containers.${cfg.containerName} = {
        autoStart = true;
        ephemeral = true;

        bindMounts.qbt-data = {
          hostPath = cfg.dataDir;
          mountPoint = cfg.dataDir;
          isReadOnly = false;
        };

        privateNetwork = true;
        extraVeths = {
          ${cfg.p2p.veth} = {inherit (cfg.p2p) hostBridge;};
          ${cfg.monitoring.veth} = {inherit (cfg.monitoring) hostAddress localAddress;};
        };

        config = {config, ...}: {
          imports = [../../../modules/nixos/common/services/qbittorrent.nix];

          users = {
            users.${cfg.user.name} = {
              uid = cfg.user.id;
              group = cfg.group.name;
              isSystemUser = true;
            };
            groups.${cfg.group.name}.gid = cfg.group.id;
          };

          networking = {
            enableIPv6 = true;

            useNetworkd = true;

            interfaces = {
              ${cfg.p2p.veth}.useDHCP = true;
            };

            useHostResolvConf = mkForce false;

            nftables.enable = true;
            firewall = {
              enable = true;
              interfaces.${cfg.monitoring.veth}.allowedTCPPorts = [
                cfg.monitoring.uiPort
                config.services.prometheus.exporters.node.port
              ];
              interfaces.${cfg.p2p.veth} = {
                allowedTCPPorts = [cfg.p2p.port];
                allowedUDPPorts = [cfg.p2p.port];
              };
            };
          };

          systemd = {
            services = {
              qbittorrent-alt-ui = {
                wantedBy = ["multi-user.target"];
                before = ["${config.services.qbittorrent.systemdServiceName}.service"];
                serviceConfig = {
                  User = cfg.user.name;
                  Group = cfg.group.name;
                  Type = "oneshot";
                  Restart = "no";
                };
                script = ''
                  if [ -L ${cfg.altUI.mountPoint} ]; then
                    unlink ${cfg.altUI.mountPoint}
                  fi
                  ln -s ${cfg.altUI.package} ${cfg.altUI.mountPoint}
                '';
              };
            };
            network = {
              wait-online.ignoredInterfaces = [cfg.p2p.veth];
              # HACK: SLAAC doesn't work unless this is set to true
              networks = {
                "40-${cfg.p2p.veth}".networkConfig = {
                  IPv6AcceptRA = true;
                  IPv6PrivacyExtensions = "kernel";
                };
                "40-${cfg.monitoring.veth}" = {
                  matchConfig.Name = cfg.monitoring.veth;
                  linkConfig.Unmanaged = true;
                };
              };
            };
          };

          services = {
            resolved.enable = true;
            qbittorrent = {
              enable = true;
              user = cfg.user.name;
              group = cfg.group.name;
              package = cfg.qbtPackage;
              inherit (cfg) dataDir;
              openFilesLimit = 65536;
              port = cfg.monitoring.uiPort;
              openFirewall = false;
              confirmLegalNotice = true;
            };
            prometheus.exporters.node.enable = true;
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
                rule = "PathPrefix(`${cfg.reverseProxyPrefix}`)";
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
                regex = "^(.*)${cfg.reverseProxyPrefix}$";
                replacement = "$1${cfg.reverseProxyPrefix}/";
              };
              qbittorrentStripPrefix.stripPrefix.prefixes = ["${cfg.reverseProxyPrefix}/"];
            };
            services = {
              qbittorrent.loadBalancer = {
                passHostHeader = false;
                servers = [
                  {
                    url = "http://${cfg.monitoring.localAddress}:${builtins.toString cfg.monitoring.uiPort}";
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
                  "${cfg.monitoring.localAddress}:${toString config.containers.${cfg.containerName}.config.services.prometheus.exporters.node.port}"
                ];
                labels.instance = "${config.networking.hostName}-qbt";
              }
            ];
          }
        ];
      };
    })
  ];
}

{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption mkIf mkForce mkEnableOption optionalAttrs nameValuePair listToAttrs;
  cfg = config.hestia.containers.qbittorrent;

  dataDirContainerPath = "/data/qbittorrent";
  mkPathInDataDir = rel: "${dataDirContainerPath}/${rel}";
  incompletePath = mkPathInDataDir "incomplete";
  mkCatPathInDataDir = cat: mkPathInDataDir "downloads/${cat}";
in {
  options.hestia.containers.qbittorrent = {
    enable = mkEnableOption "qbittorrent container";

    containerName = mkOption {type = types.str;};

    qbtPackage = mkOption {type = types.package;};

    dataDir = mkOption {type = types.path;};
    dataDirContainer = mkOption {
      type = types.path;
      default = dataDirContainerPath;
      readOnly = true;
    };

    user = {
      name = mkOption {type = types.str;};
      id = mkOption {type = types.int;};
    };
    group = {
      name = mkOption {type = types.str;};
      id = mkOption {type = types.int;};
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
      ui = {
        port = mkOption {type = types.port;};
        passwordHash = mkOption {
          type = types.str;
          description = "Password_PBKDF2";
        };
        altPackage = mkOption {
          type = types.nullOr types.package;
          default = null;
        };
      };
    };

    reverseProxyPrefix = mkOption {type = types.str;};

    systemdServiceName = mkOption {
      type = types.str;
      default = "qbittorrent";
      readOnly = true;
    };

    categories = mkOption {
      type = types.listOf types.str;
      default = [];
    };
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
      systemd = {
        services."container@${cfg.containerName}" = {
          # HACK
          postStart = ''
            # Don't let tailscale hijack the traffic in and out of the monitoring veth
            ip route add throw ${cfg.monitoring.localAddress} table 52
          '';
          preStop = ''
            ip route delete throw ${cfg.monitoring.localAddress} table 52
          '';
        };
        network.networks."40-${cfg.monitoring.veth}" = {
          matchConfig.Name = cfg.monitoring.veth;
          linkConfig.Unmanaged = true;
        };
      };

      containers.${cfg.containerName} = {
        autoStart = false;
        ephemeral = true;

        bindMounts.qbt-data = {
          hostPath = cfg.dataDir;
          mountPoint = cfg.dataDirContainer;
          isReadOnly = false;
        };

        privateNetwork = true;
        extraVeths = {
          ${cfg.p2p.veth} = {inherit (cfg.p2p) hostBridge;};
          ${cfg.monitoring.veth} = {inherit (cfg.monitoring) hostAddress localAddress;};
        };

        config = {config, ...}: {
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
                cfg.monitoring.ui.port
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
              ${cfg.systemdServiceName}.serviceConfig.LimitNOFILE = 65536;
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
            tmpfiles.settings."10-qbt-categories" = let
              genCfg = cat:
                nameValuePair (mkCatPathInDataDir cat) {
                  d = {
                    user = cfg.user.name;
                    group = cfg.group.name;
                    mode = "0755";
                  };
                };
            in
              listToAttrs (map genCfg cfg.categories);
          };

          services = {
            resolved.enable = true;
            qbittorrent = {
              enable = true;
              user = cfg.user.name;
              group = cfg.group.name;
              package = cfg.qbtPackage;
              profileDir = cfg.dataDirContainer;
              webuiPort = cfg.monitoring.ui.port;
              torrentingPort = cfg.p2p.port;
              # NOTE: this is handled ourselves. We need to open the ports on different interfaces.
              openFirewall = false;

              # TODO: Manage category, generate a json file
              serverConfig = {
                LegalNotice.Accepted = true;
                BitTorrent = {
                  Session = {
                    GlobalDLSpeedLimit = 0;
                    # TODO: expose this as an option?
                    GlobalUPSpeedLimit = 10240;
                    IgnoreLimitsOnLan = true;
                    Interface = cfg.p2p.veth;
                    InterfaceName = cfg.p2p.veth;
                    Port = cfg.p2p.port;
                    TempPathEnabled = true;
                    TempPath = incompletePath;
                  };
                };
                Core.AutoDeleteAddedTorrentFile = "Never";
                Preferences = {
                  General.Locale = "en";
                  WebUI =
                    {
                      Password_PBKDF2 = ''"@ByteArray(${cfg.monitoring.ui.passwordHash})"'';
                      UseUPnP = false;
                    }
                    // (optionalAttrs (cfg.monitoring.ui.altPackage != null) {
                      AlternativeUIEnabled = true;
                      RootFolder = "${toString cfg.monitoring.ui.altPackage}";
                    });
                };
                RSS = {
                  Session = {
                    EnableProcessing = true;
                    RefreshInterval = 10;
                  };
                  AutoDownloader = {
                    EnableProcessing = true;
                    DownloadRepacks = true;
                    # TODO: expose this as an option? It doesn't make sense to hardcode this but I never used it.
                    SmartEpisodeFilters = ''s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"'';
                  };
                };
              };
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
                    url = "http://${cfg.monitoring.localAddress}:${builtins.toString cfg.monitoring.ui.port}";
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

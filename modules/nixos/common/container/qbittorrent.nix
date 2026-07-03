{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit
    (lib)
    types
    mkOption
    mkEnableOption
    mkMerge
    mkIf
    mkForce
    mkDefault
    optionalAttrs
    ;
  inherit (builtins) toString;

  defaultDownloadsDir = "${cfg.profileDir}/downloads";
  defaultIncompleteDownloadsDir = "${cfg.profileDir}/incomplete";

  cfg = config.dotfiles.nixos.containers.qbittorrent;

  userAndGroupConfig = {
    users = {
      users.${cfg.user.name} = {
        uid = cfg.user.id;
        group = cfg.group.name;
        isSystemUser = true;
      };
      groups.${cfg.group.name}.gid = cfg.group.id;
    };
  };

  middlewareSetHeadersName = "${cfg.containerName}SetHeaders";
  middlewareRedirectName = "${cfg.containerName}Redirect";
  middlewareStripPrefixName = "${cfg.containerName}StripPrefix";
in {
  options.dotfiles.nixos.containers.qbittorrent = {
    enable = mkEnableOption "qbittorrent container";

    autoStart = mkOption {
      type = types.bool;
      default = true;
    };

    containerName = mkOption {
      type = types.str;
      default = "qbt";
    };

    qbtPackage = mkOption {
      type = types.package;
      default = pkgs.qbittorrent-nox;
    };
    qbtConfig = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf (types.attrsOf types.anything);
      };
      default = {};
    };

    altUIPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
    };

    profileDir = mkOption {
      type = types.path;
      default = "/data/qbittorrent";
    };
    profileDirContainer = mkOption {
      type = types.nullOr types.path;
      default = cfg.profileDir;
      readOnly = true;
    };

    defaultDownloadsDir = mkOption {
      type = types.path;
      default = defaultDownloadsDir;
    };
    defaultIncompleteDownloadsDir = mkOption {
      type = types.path;
      default = defaultIncompleteDownloadsDir;
    };

    user = {
      name = mkOption {
        type = types.str;
        default = "qbittorrent";
      };
      id = mkOption {type = types.int;};
    };
    group = {
      name = mkOption {
        type = types.str;
        default = "qbittorrent";
      };
      id = mkOption {type = types.int;};
    };

    p2p = {
      veth = mkOption {
        type = types.str;
        default = "${cfg.containerName}-p2p";
      };
      port = mkOption {
        type = types.port;
        default = 10269;
      };
      hostBridge = mkOption {type = types.str;};
    };

    monitoring = {
      veth = mkOption {
        type = types.str;
        default = "${cfg.containerName}-mon";
      };
      hostAddress = mkOption {type = types.str;};
      localAddress = mkOption {type = types.str;};
      uiPort = mkOption {
        type = types.port;
        default = 8080;
      };
    };

    reverseProxy = {
      enable = mkEnableOption "traefik reverse proxy setup";

      prefix = mkOption {
        type = types.str;
        default = "/qbittorrent";
      };

      authMiddleware = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };

    timeZone = mkOption {
      type = types.nullOr types.str;
      default = config.time.timeZone;
    };

    systemdServiceName = mkOption {
      type = types.str;
      default = "container@${cfg.containerName}";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      containers.${cfg.containerName} = {
        inherit (cfg) autoStart;
        ephemeral = true;
        config = {
          services.prometheus.exporters.node.enable = true;

          time = {inherit (cfg) timeZone;};

          system.stateVersion = "24.11";
        };
      };
    }

    # MARK: User and Group
    userAndGroupConfig # On host
    {
      containers.${cfg.containerName}.config = userAndGroupConfig;
    }

    # MARK: Filesystem
    {
      systemd.tmpfiles.settings."10-qbittorrent-profile" =
        {
          ${cfg.profileDir}.d = {
            user = cfg.user.name;
            group = cfg.group.name;
            mode = "0775";
          };
          ${cfg.defaultDownloadsDir}.d = {
            user = cfg.user.name;
            group = cfg.group.name;
            mode = "0775";
          };
        }
        // (optionalAttrs (cfg.defaultIncompleteDownloadsDir != null) {
          ${cfg.defaultIncompleteDownloadsDir}.d = {
            user = cfg.user.name;
            group = cfg.group.name;
            mode = "0775";
          };
        });

      containers.${cfg.containerName}.bindMounts.qbt-profile = {
        hostPath = cfg.profileDir;
        mountPoint = cfg.profileDirContainer;
        isReadOnly = false;
      };
    }

    # MARK: Networking
    {
      systemd = {
        services.${cfg.systemdServiceName} = {
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
        privateNetwork = true;
        extraVeths = {
          ${cfg.p2p.veth} = {inherit (cfg.p2p) hostBridge;};
          ${cfg.monitoring.veth} = {inherit (cfg.monitoring) hostAddress localAddress;};
        };

        config = {config, ...}: {
          networking = {
            enableIPv6 = true;

            useNetworkd = true;

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

          systemd.network = {
            wait-online.enable = false;
            # wait-online.ignoredInterfaces = [ cfg.p2p.veth ];
            # HACK: SLAAC doesn't work unless this is set to true
            networks = {
              "10-${cfg.p2p.veth}" = {
                matchConfig.Name = cfg.p2p.veth;
                networkConfig = {
                  DHCP = true;
                  # HACK: SLAAC doesn't work unless this is set to true
                  IPv6AcceptRA = true;
                  IPv6PrivacyExtensions = "kernel";
                };
              };
              "10-${cfg.monitoring.veth}" = {
                matchConfig.Name = cfg.monitoring.veth;
                linkConfig.Unmanaged = true;
              };
            };
          };
        };
      };

      services.resolved.enable = true;
    }

    # MARK: Default Server Configs
    {
      dotfiles.nixos.containers.qbittorrent.qbtConfig = {
        LegalNotice.Accepted = true;
        BitTorrent = {
          MergeTrackersEnabled = mkDefault true;
          Session = {
            DefaultSavePath = cfg.defaultDownloadsDir;
            GlobalDLSpeedLimit = mkDefault 0;
            GlobalUPSpeedLimit = mkDefault 40960;
            IgnoreLimitsOnLAN = true;
            Interface = cfg.p2p.veth;
            InterfaceName = cfg.p2p.veth;
            Port = cfg.p2p.port;
            MaxActiveCheckingTorrents = 64;
            MaxActiveDownloads = 64;
            MaxActiveUploads = 64;
            MaxActiveTorrents = 128;
            QueueingSystemEnabled = true;
            AddExtensionToIncompleteFiles = true;
            AddTorrentToTopOfQueue = true;
            IgnoreSlowTorrentsForQueueing = true;
          };
        };
        Preferences = {
          General.Locale = "en";
          WebUI = {
            AuthSubnetWhitelist = mkDefault "${cfg.monitoring.hostAddress}/32";
            AuthSubnetWhitelistEnabled = mkDefault true;
            UseUPnP = false;
          };
        };
        RSS = {
          Session = {
            EnableProcessing = mkDefault true;
            RefreshInterval = mkDefault 10;
          };
          AutoDownloader.EnableProcessing = mkDefault true;
        };
      };
    }
    (mkIf (cfg.altUIPackage != null) {
      dotfiles.nixos.containers.qbittorrent.qbtConfig.Preferences.WebUI = {
        AlternativeUIEnabled = true;
        RootFolder = "${cfg.altUIPackage}";
      };
    })
    (mkIf (cfg.defaultIncompleteDownloadsDir != null) {
      dotfiles.nixos.containers.qbittorrent.qbtConfig.BitTorrent.Session = {
        TempPathEnabled = true;
        TempPath = cfg.defaultIncompleteDownloadsDir;
      };
    })

    # MARK: QBittorrent
    {
      containers.${cfg.containerName}.config.services.qbittorrent = {
        enable = true;
        user = cfg.user.name;
        group = cfg.group.name;
        inherit (cfg) profileDir;
        webuiPort = cfg.monitoring.uiPort;
        torrentingPort = cfg.p2p.port;
        serverConfig = cfg.qbtConfig;
      };
    }

    (mkIf cfg.reverseProxy.enable {
      services.traefik.dynamicConfigOptions = {
        http = {
          routers = {
            qbittorrent = {
              service = cfg.containerName;
              rule = "PathPrefix(`${cfg.reverseProxy.prefix}`)";
              middlewares =
                [
                  middlewareRedirectName
                ]
                ++ lib.optional (cfg.reverseProxy.authMiddleware != null) cfg.reverseProxy.authMiddleware
                ++ [
                  middlewareStripPrefixName
                  middlewareSetHeadersName
                ];
            };
          };
          middlewares = {
            ${middlewareSetHeadersName}.headers.customRequestHeaders = {
              X-Frame-Options = "SAMEORIGIN";
              Referer = "";
              Origin = "";
            };
            ${middlewareRedirectName}.redirectRegex = {
              regex = "^(.*)${cfg.reverseProxy.prefix}$";
              replacement = "$1${cfg.reverseProxy.prefix}/";
            };
            ${middlewareStripPrefixName}.stripPrefix.prefixes = ["${cfg.reverseProxy.prefix}/"];
          };
          services = {
            ${cfg.containerName}.loadBalancer = {
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
    })

    {
      services.prometheus.scrapeConfigs = [
        {
          job_name = "${config.networking.hostName}-qbt-node";
          static_configs = [
            {
              targets = [
                "${cfg.monitoring.localAddress}:${
                  toString config.containers.${cfg.containerName}.config.services.prometheus.exporters.node.port
                }"
              ];
              labels.instance = "${config.networking.hostName}-qbt";
            }
          ];
        }
      ];
    }
  ]);
}

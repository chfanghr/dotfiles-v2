{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) types mkOption mkIf mkForce mkEnableOption attrValues;
  cfg = config.hestia.containers.minecraft;
in {
  options.hestia.containers.minecraft = {
    enable = mkEnableOption "minecraft container";

    containerName = mkOption {type = types.str;};

    user = {
      name = mkOption {type = types.str;};
      id = mkOption {type = types.int;};
    };
    group = {
      name = mkOption {type = types.str;};
      id = mkOption {type = types.int;};
    };

    lan = {
      veth = mkOption {type = types.str;};
      hostBridge = mkOption {type = types.str;};
    };

    monitoring = {
      veth = mkOption {type = types.str;};
      hostAddress = mkOption {type = types.str;};
      localAddress = mkOption {type = types.str;};
    };

    worldsDir = mkOption {type = types.path;};

    smp = {
      worldName = mkOption {type = types.str;};

      serverPackage = mkOption {type = types.package;};

      mods = mkOption {type = types.attrsOf types.package;};

      carpetConfig = mkOption {type = types.str;};

      port = mkOption {type = types.port;};

      otherSettings = mkOption {type = types.attrs;};

      jvmOptions = mkOption {type = types.str;};
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
    }
    (
      mkIf cfg.enable {
        containers.${cfg.containerName} = {
          autoStart = true;

          privateNetwork = true;
          enableTun = true;
          extraVeths = {
            ${cfg.lan.veth} = {inherit (cfg.lan) hostBridge;};
            ${cfg.monitoring.veth} = {inherit (cfg.monitoring) hostAddress localAddress;};
          };

          bindMounts.minecraft-data = {
            hostPath = cfg.worldsDir;
            mountPoint = cfg.worldsDir;
            isReadOnly = false;
          };

          config = {config, ...}: {
            imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

            networking = {
              enableIPv6 = true;

              useNetworkd = true;

              useDHCP = false;

              interfaces.${cfg.lan.veth}.useDHCP = true;

              useHostResolvConf = mkForce false;

              firewall = {
                enable = true;
                interfaces = {
                  ${cfg.monitoring.veth}.allowedTCPPorts = [
                    config.services.prometheus.exporters.node.port
                  ];
                  ${config.services.tailscale.interfaceName} = {
                    allowedTCPPorts = [
                      cfg.smp.port
                    ];
                    allowedUDPPorts = [
                      24454 # Simple Voice Chat
                    ];
                  };
                };
              };
            };

            services = {
              resolved.enable = true;
              tailscale.enable = true;
              prometheus.exporters.node.enable = true;
              minecraft-servers = {
                enable = true;
                eula = true;
                servers = {
                  ${cfg.smp.worldName} = {
                    enable = true;
                    package = cfg.smp.serverPackage;
                    serverProperties =
                      cfg.smp.otherSettings
                      // {
                        server-port = cfg.smp.port;
                      };
                    files = {
                      "world/carpet.conf" = "${pkgs.writeText "carpet.conf" cfg.smp.carpetConfig}";
                    };
                    symlinks = {
                      "mods" = "${pkgs.linkFarmFromDrvs "mods" (attrValues cfg.smp.mods)}";
                    };
                    jvmOpts = "-Xmx8192M";
                  };
                };
              };
            };

            fileSystems."${config.services.minecraft-servers.dataDir}/${cfg.smp.worldName}/world" = {
              device = "${cfg.worldsDir}/smp";
              options = ["bind"];
            };

            users = {
              users.minecraft.uid = cfg.user.id;
              groups.minecraft.gid = cfg.group.id;
            };

            systemd = {
              # HACK
              services.minecraft-server-smp = {
                after = ["srv-minecraft-smp-world.mount"];
                bindsTo = ["srv-minecraft-smp-world.mount"];
              };

              network = {
                wait-online.ignoredInterfaces = [cfg.lan.veth];
                networks = {
                  "40-${cfg.lan.veth}".networkConfig = {
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

            environment.systemPackages = [
              pkgs.rcon
            ];

            time.timeZone = "Asia/Hong_Kong";
            system.stateVersion = "24.11";
          };
        };

        services.prometheus.scrapeConfigs = [
          {
            job_name = "${config.networking.hostName}-minecraft-node";
            static_configs = [
              {
                targets = [
                  "${cfg.monitoring.localAddress}:${toString config.containers.${cfg.containerName}.config.services.prometheus.exporters.node.port}"
                ];
                labels.instance = "${config.networking.hostName}-minecraft";
              }
            ];
          }
        ];

        # HACK
        systemd = {
          services."container@minecraft" = {
            after = ["data-minecraft-smp.mount"];
            bindsTo = ["data-minecraft-smp.mount"];
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
      }
    )
  ];
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkForce mkMerge;
  inherit (builtins) toString;

  vpnServerCfg = config.athena.networking.vpnServerConfig;
  gatewayCfg = config.athena.networking.vpnGateway;
  gatewayDPCfg = config.athena.networking.vpnGatewayDebugProbe;
  proxyCfg = config.athena.networking.vpnProxy;
in {
  options.athena.networking = {
    mainRouterAddress = mkOption {type = types.str;};

    lanAddressPrefixLen = mkOption {type = types.ints.unsigned;};

    vpnServerConfig = {
      encryptedFile = mkOption {type = types.pathInStore;};

      secretName = mkOption {
        type = types.str;
        default = "vpn-server-config";
        readOnly = true;
        internal = true;
      };

      mountPoint = mkOption {
        type = types.path;
        default = "/tmp/proxy-config.json";
        readOnly = true;
        internal = true;
      };
    };

    vpnGateway = {
      containerName = mkOption {type = types.str;};

      address = mkOption {type = types.str;};

      tunInterface = mkOption {
        type = types.str;
        default = "tun0";
        readOnly = true;
        internal = true;
      };

      lanInterface = mkOption {
        type = types.str;
        default = "eth0";
        readOnly = true;
        internal = true;
      };

      persistentState.hostPath = mkOption {type = types.path;};
    };

    vpnProxy = {
      containerName = mkOption {type = types.str;};

      address = mkOption {type = types.str;};

      lanInterface = mkOption {
        type = types.str;
        default = "eth0";
        readOnly = true;
        internal = true;
      };

      dnsPort = mkOption {type = types.port;};
      httpPort = mkOption {type = types.port;};
      socksPort = mkOption {type = types.port;};

      persistentState.hostPath = mkOption {type = types.path;};
    };

    vpnGatewayDebugProbe = {
      containerName = mkOption {type = types.str;};

      address = mkOption {type = types.str;};

      lanInterface = mkOption {
        type = types.str;
        default = "eth0";
        readOnly = true;
        internal = true;
      };
    };
  };

  config = mkMerge [
    {
      athena.networking = {
        mainRouterAddress = "10.41.0.1";

        lanAddressPrefixLen = 16;

        vpnServerConfig.encryptedFile = ../../secrets/athena-sing-box-default-out.age;

        vpnGateway = {
          containerName = "vpn-gateway";
          address = "10.41.0.2";
          persistentState.hostPath = "/var/lib/vpn-gateway";
        };

        vpnProxy = {
          containerName = "vpn-proxy";
          address = "10.41.0.3";
          dnsPort = 53;
          socksPort = 1080;
          httpPort = 8080;
          persistentState.hostPath = "/var/lib/vpn-proxy";
        };

        vpnGatewayDebugProbe = {
          containerName = "vpn-gateway-debug-probe";
          address = "10.41.0.110";
        };
      };
    }
    {
      age.secrets.${vpnServerCfg.secretName}.file = vpnServerCfg.encryptedFile;
    }
    {
      environment.persistence.${config.athena.persistPath}.directories = [
        {
          directory = proxyCfg.persistentState.hostPath;
          mode = "u=rwx,g=,o=";
        }
      ];

      containers.${proxyCfg.containerName} = {
        autoStart = true;

        ephemeral = true;

        privateNetwork = true;
        hostBridge = config.athena.networking.lanBridge.interface;

        bindMounts = {
          vpnServerConfig = {
            mountPoint = vpnServerCfg.mountPoint;
            hostPath = config.age.secrets.${vpnServerCfg.secretName}.path;
          };
          singBoxState = {
            isReadOnly = false;
            mountPoint = "/var/lib/sing-box/";
            hostPath = proxyCfg.persistentState.hostPath;
          };
        };

        config = {
          networking = {
            useNetworkd = true;

            nftables.enable = true;

            firewall = {
              enable = true;

              interfaces.${proxyCfg.lanInterface} = {
                allowedTCPPorts = [
                  proxyCfg.httpPort
                  proxyCfg.socksPort
                ];
                allowedUDPPorts = [
                  proxyCfg.dnsPort
                ];
              };
            };

            useHostResolvConf = mkForce false;

            enableIPv6 = true;
          };

          services = {
            resolved.enable = false;
            sing-box = {
              enable = true;
              settings = {
                log.level = "info";
                experimental = {
                  cache_file = {
                    enabled = true;
                    path = "cache.db";
                    store_rdrc = true;
                  };
                };
                dns = {
                  servers = [
                    {
                      tag = "dns-bootstrap";
                      address = "223.5.5.5";
                      detour = "direct-out";
                    }
                    {
                      tag = "dns-direct";
                      address = "https://dns.alidns.com/dns-query";
                      address_resolver = "dns-bootstrap";
                      detour = "direct-out";
                    }
                    {
                      tag = "dns-proxy";
                      address = "https://1.1.1.1/dns-query";
                      address_resolver = "dns-direct";
                      detour = "proxy-out";
                      strategy = "ipv4_only";
                    }
                  ];
                  rules = [
                    {
                      outbound = "any";
                      server = "dns-bootstrap";
                    }
                    {
                      rule_set = "geosite-geolocation-cn";
                      server = "dns-direct";
                    }
                  ];
                  final = "dns-proxy";
                  independent_cache = true;
                };
                inbounds = [
                  {
                    type = "direct";
                    tag = "dns-in";
                    listen = "0.0.0.0";
                    listen_port = proxyCfg.dnsPort;
                    sniff = true;
                    sniff_override_destination = false;
                  }
                  {
                    type = "http";
                    tag = "http-in";
                    listen = "0.0.0.0";
                    listen_port = proxyCfg.httpPort;
                    users = [];
                    sniff = true;
                    sniff_override_destination = false;
                  }
                  {
                    type = "socks";
                    tag = "socks-in";
                    listen = "0.0.0.0";
                    listen_port = proxyCfg.socksPort;
                    users = [];
                    sniff = true;
                    sniff_override_destination = false;
                  }
                ];
                outbounds = [
                  {
                    # tag = "proxy-out";
                    _secret = vpnServerCfg.mountPoint;
                    quote = false;
                  }
                  {
                    type = "dns";
                    tag = "dns-out";
                  }
                  {
                    type = "direct";
                    tag = "direct-out";
                  }
                  {
                    type = "block";
                    tag = "block-out";
                  }
                ];
                route = {
                  rules = [
                    {
                      action = "sniff";
                    }
                    {
                      protocol = "dns";
                      outbound = "dns-out";
                    }
                    {
                      protocol = "bittorrent";
                      action = "reject";
                    }
                    {
                      protocol = "stun";
                      outbound = "direct-out";
                    }
                    {
                      ip_is_private = true;
                      outbound = "direct-out";
                    }
                    {
                      network = ["udp"];
                      source_port = [41641];
                      outbound = "direct-out";
                    }
                    {
                      network = ["udp"];
                      port = [41641];
                      outbound = "direct-out";
                    }
                    {
                      rule_set = ["geoip-cn"];
                      outbound = "direct-out";
                    }
                    {
                      ip_is_private = true;
                      action = "reject";
                    }
                  ];
                  rule_set = [
                    {
                      format = "binary";
                      path = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-geolocation-cn.srs";
                      tag = "geosite-geolocation-cn";
                      type = "local";
                    }
                    {
                      format = "binary";
                      path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-cn.srs";
                      tag = "geoip-cn";
                      type = "local";
                    }
                  ];
                  final = "proxy-out";
                  default_interface = proxyCfg.lanInterface;
                };
              };
            };
          };

          systemd.network = {
            wait-online.enable = false;
            networks."40-${proxyCfg.lanInterface}" = {
              matchConfig.Name = proxyCfg.lanInterface;
              networkConfig = {
                DHCP = "no";
                Address = "${proxyCfg.address}/${toString config.athena.networking.lanAddressPrefixLen}";
                IPv6AcceptRA = true;
                Gateway = config.athena.networking.mainRouterAddress;
              };
            };
          };

          time.timeZone = "Asia/Hong_Kong";

          system.stateVersion = "25.03";
        };
      };

      systemd.services."container@${proxyCfg.containerName}".restartTriggers = [
        config.age.secrets.${vpnServerCfg.secretName}.file
      ];
    }
    {
      environment.persistence.${config.athena.persistPath}.directories = [
        {
          directory = gatewayCfg.persistentState.hostPath;
          mode = "u=rwx,g=,o=";
        }
      ];

      containers.${gatewayCfg.containerName} = {
        autoStart = true;

        ephemeral = true;

        privateNetwork = true;
        enableTun = true;
        hostBridge = config.athena.networking.lanBridge.interface;

        bindMounts = {
          vpnServerConfig = {
            mountPoint = vpnServerCfg.mountPoint;
            hostPath = config.age.secrets.${vpnServerCfg.secretName}.path;
          };
          singBoxState = {
            isReadOnly = false;
            mountPoint = "/var/lib/sing-box/";
            hostPath = gatewayCfg.persistentState.hostPath;
          };
        };

        config = {
          networking = {
            useNetworkd = true;

            nftables.enable = true;

            firewall.enable = false;

            useHostResolvConf = mkForce false;

            enableIPv6 = true;
          };

          services = {
            resolved.enable = false;
            sing-box = {
              enable = true;
              settings = {
                log.level = "info";
                experimental = {
                  cache_file = {
                    enabled = true;
                    path = "cache.db";
                    store_rdrc = true;
                  };
                };
                dns = {
                  servers = [
                    {
                      tag = "dns-bootstrap";
                      address = "223.5.5.5";
                      detour = "direct-out";
                    }
                    {
                      tag = "dns-direct";
                      address = "https://dns.alidns.com/dns-query";
                      address_resolver = "dns-bootstrap";
                      detour = "direct-out";
                    }
                    {
                      tag = "dns-proxy";
                      address = "https://1.1.1.1/dns-query";
                      address_resolver = "dns-direct";
                      detour = "proxy-out";
                      strategy = "ipv4_only";
                    }
                  ];
                  rules = [
                    {
                      outbound = "any";
                      server = "dns-bootstrap";
                    }
                    {
                      rule_set = "geosite-geolocation-cn";
                      server = "dns-direct";
                    }
                  ];
                  final = "dns-proxy";
                  independent_cache = true;
                };
                inbounds = [
                  {
                    type = "tun";
                    tag = "tun-in";
                    interface_name = gatewayCfg.tunInterface;
                    address = ["172.18.0.1/30" "fd00::1/126"];
                    mtu = 9000;
                    auto_route = true;
                    auto_redirect = true;
                    strict_route = true;
                    stack = "system";
                    sniff = true;
                    sniff_override_destination = true;
                  }
                ];
                outbounds = [
                  {
                    # tag = "proxy-out";
                    _secret = vpnServerCfg.mountPoint;
                    quote = false;
                  }
                  {
                    type = "dns";
                    tag = "dns-out";
                  }
                  {
                    type = "direct";
                    tag = "direct-out";
                  }
                  {
                    type = "block";
                    tag = "block-out";
                  }
                ];
                route = {
                  rules = [
                    {
                      action = "sniff";
                    }
                    {
                      protocol = "dns";
                      action = "hijack-dns";
                    }
                    {
                      protocol = "bittorrent";
                      action = "reject";
                    }
                    {
                      protocol = "stun";
                      outbound = "direct-out";
                    }
                    {
                      network = ["udp"];
                      source_port = [41641];
                      outbound = "direct-out";
                    }
                    {
                      network = ["udp"];
                      port = [41641];
                      outbound = "direct-out";
                    }
                    {
                      rule_set = ["geoip-cn"];
                      outbound = "direct-out";
                    }
                    {
                      ip_is_private = true;
                      action = "reject";
                    }
                  ];
                  rule_set = [
                    {
                      format = "binary";
                      path = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-geolocation-cn.srs";
                      tag = "geosite-geolocation-cn";
                      type = "local";
                    }
                    {
                      format = "binary";
                      path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-cn.srs";
                      tag = "geoip-cn";
                      type = "local";
                    }
                  ];
                  final = "proxy-out";
                  default_interface = gatewayCfg.lanInterface;
                };
              };
            };
          };

          systemd.network = {
            wait-online.enable = false;
            networks = {
              "40-${gatewayCfg.lanInterface}" = {
                matchConfig.Name = gatewayCfg.lanInterface;
                networkConfig = {
                  DHCP = "no";
                  Address = "${gatewayCfg.address}/${toString config.athena.networking.lanAddressPrefixLen}";
                  IPv6AcceptRA = true;
                  Gateway = config.athena.networking.mainRouterAddress;
                };
              };
              "40-${gatewayCfg.tunInterface}" = {
                matchConfig.Name = gatewayCfg.tunInterface;
                linkConfig = {
                  ActivationPolicy = "manual";
                  Unmanaged = true;
                };
              };
            };
          };

          boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv4.conf.all.forwarding" = 1;
            "net.ipv6.conf.all.forwarding" = 1;
            "net.ipv6.conf.default.forwarding" = 1;
          };

          time.timeZone = "Asia/Hong_Kong";

          system.stateVersion = "25.03";
        };
      };

      systemd.services."container@${gatewayCfg.containerName}".restartTriggers = [
        config.age.secrets.${vpnServerCfg.secretName}.file
      ];
    }
    {
      containers.${gatewayDPCfg.containerName} = {
        autoStart = true;

        ephemeral = true;

        privateNetwork = true;
        hostBridge = config.athena.networking.lanBridge.interface;

        config = {
          lib,
          pkgs,
          ...
        }: {
          networking = {
            useNetworkd = true;

            nftables.enable = true;
            firewall.enable = true;

            useHostResolvConf = lib.mkForce false;

            enableIPv6 = true;

            nameservers = [
              "1.1.1.1"
              "8.8.8.8"
            ];
          };

          services.resolved.enable = true;

          systemd.network = {
            wait-online.enable = false;
            networks."40-eth0" = {
              matchConfig.Name = gatewayDPCfg.lanInterface;
              networkConfig = {
                DHCP = false;
                Address = "${gatewayDPCfg.address}/${toString config.athena.networking.lanAddressPrefixLen}";
                Gateway = gatewayCfg.address;
              };
            };
          };

          environment.systemPackages = with pkgs; [
            dig
            curl
            trippy
            ethtool
          ];

          time.timeZone = "Asia/Hong_Kong";
          system.stateVersion = "25.05";
        };
      };
    }
  ];
}

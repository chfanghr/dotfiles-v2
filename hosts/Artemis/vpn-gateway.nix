{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkOption types mkForce;

  cfg = config.artemis.networking.vpnGateway;

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
  };
in {
  options.artemis.networking.vpnGateway = {
    address = mkOption {type = types.str;};
    mainRouterAddress = mkOption {
      type = types.str;
      default = "10.31.0.1";
      readOnly = true;
      internal = true;
    };

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

  config = {
    artemis.networking.vpnGateway = {
      address = "10.31.0.100/16";
      vpnServerConfig.encryptedFile = ../../secrets/vpn-gateway-experimental-proxy-out.age;
      persistentState.hostPath = "/var/lib/sing-box/";
    };

    age.secrets.${cfg.vpnServerConfig.secretName}.file =
      cfg.vpnServerConfig.encryptedFile;

    systemd.tmpfiles.settings."10-vpn-gateway-state".${cfg.persistentState.hostPath}.d = {
      user = "root";
      group = "root";
      mode = "0700";
    };

    containers.vpn-gateway = {
      autoStart = true;

      ephemeral = true;

      privateNetwork = true;
      enableTun = true;

      hostBridge = config.artemis.networking.lanBridge.interface;

      bindMounts = {
        vpnServerConfig = {
          mountPoint = cfg.vpnServerConfig.mountPoint;
          hostPath = config.age.secrets.${cfg.vpnServerConfig.secretName}.path;
        };
        singBoxState = {
          isReadOnly = false;
          mountPoint = "/var/lib/sing-box/";
          hostPath = cfg.persistentState.hostPath;
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

        services.sing-box = {
          enable = true;
          package = pkgsUnstable.sing-box;
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
                interface_name = cfg.tunInterface;
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
                _secret = cfg.vpnServerConfig.mountPoint;
                quote = false;
              }
              {
                type = "direct";
                tag = "direct-out";
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
              default_interface = "eth0";
            };
          };
        };

        systemd.network = {
          wait-online.enable = false;
          networks = {
            "40-${cfg.lanInterface}" = {
              matchConfig.Name = cfg.lanInterface;
              networkConfig = {
                DHCP = "no";
                Address = cfg.address;
                IPv6AcceptRA = true;
                Gateway = cfg.mainRouterAddress;
              };
            };
            "40-${cfg.tunInterface}" = {
              matchConfig.Name = cfg.tunInterface;
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

        system.stateVersion = "24.11";
      };
    };
  };
}

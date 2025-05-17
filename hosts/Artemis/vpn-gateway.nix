{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkForce;

  cfg = config.artemis.networking.vpnGateway;
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
      address = "10.31.0.100";
      vpnServerConfig.encryptedFile = ../../secrets/oizys-sing-box-default-out.age;
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
          settings = {
            dns = {
              fakeip = {
                enabled = true;
                inet4_range = "198.18.0.0/15";
                inet6_range = "fc00::/18";
              };
              final = "dns_direct";
              independent_cache = true;
              rules = [
                {
                  outbound = "any";
                  server = "dns_resolver";
                }
                {
                  query_type = ["A" "AAAA"];
                  rule_set = "geosite-geolocation-!cn";
                  server = "dns_fakeip";
                }
                {
                  query_type = ["CNAME"];
                  rule_set = "geosite-geolocation-!cn";
                  server = "dns_proxy";
                }
                {
                  disable_cache = true;
                  invert = true;
                  query_type = ["A" "AAAA" "CNAME"];
                  server = "dns_refused";
                }
              ];
              servers = [
                {
                  address = "tcp://1.1.1.1";
                  address_resolver = "dns_resolver";
                  detour = "proxy";
                  strategy = "ipv4_only";
                  tag = "dns_proxy";
                }
                {
                  address = "https://dns.alidns.com/dns-query";
                  address_resolver = "dns_resolver";
                  detour = "direct";
                  strategy = "ipv4_only";
                  tag = "dns_direct";
                }
                {
                  address = "223.5.5.5";
                  detour = "direct";
                  tag = "dns_resolver";
                }
                {
                  address = "rcode://success";
                  tag = "dns_success";
                }
                {
                  address = "rcode://refused";
                  tag = "dns_refused";
                }
                {
                  address = "fakeip";
                  tag = "dns_fakeip";
                }
              ];
            };
            experimental = {
              cache_file = {
                enabled = true;
                path = "cache.db";
                store_fakeip = true;
                store_rdrc = true;
              };
            };
            inbounds = [
              {
                address = ["172.16.0.1/30" "fd00::1/126"];
                auto_route = true;
                mtu = 1492;
                sniff = true;
                sniff_override_destination = false;
                stack = "system";
                strict_route = true;
                tag = "tun-in";
                type = "tun";
                interface_name = cfg.tunInterface;
              }
            ];
            log = {
              level = "info";
              timestamp = true;
            };
            outbounds = [
              {
                # tag = "proxy";
                _secret = cfg.vpnServerConfig.mountPoint;
                quote = false;
              }
              {
                tag = "direct";
                type = "direct";
              }
              {
                tag = "block";
                type = "block";
              }
              {
                tag = "dns-out";
                type = "dns";
              }
            ];
            route = {
              auto_detect_interface = true;
              final = "proxy";
              rule_set = [
                {
                  format = "binary";
                  path = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-geolocation-!cn.srs";
                  tag = "geosite-geolocation-!cn";
                  type = "local";
                }
                {
                  format = "binary";
                  path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-cn.srs";
                  tag = "geoip-cn";
                  type = "local";
                }
              ];
              rules = [
                {
                  outbound = "dns-out";
                  protocol = "dns";
                }
                {
                  network = "tcp";
                  outbound = "block";
                  port = 853;
                }
                {
                  network = "udp";
                  outbound = "block";
                  port = 443;
                }
                {
                  outbound = "proxy";
                  rule_set = "geosite-geolocation-!cn";
                }
                {
                  outbound = "direct";
                  rule_set = "geoip-cn";
                }
                {
                  ip_is_private = true;
                  outbound = "direct";
                }
              ];
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

        networking.nftables.tables.nat = {
          family = "ip";
          content = ''
            chain prerouting {
                type nat hook prerouting priority filter; policy accept;
            }

            chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                iifname ${cfg.lanInterface} oifname ${cfg.tunInterface} masquerade
            }
          '';
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

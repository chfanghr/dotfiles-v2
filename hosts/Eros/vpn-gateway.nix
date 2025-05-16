{config, ...}: {
  age.secrets."oizys-sing-box-default-out".file =
    ../../secrets/oizys-sing-box-default-out.age;

  containers.vpn-gateway = let
    defaultOutPathInContainer = "/tmp/default-out.json";
  in {
    autoStart = true;

    ephemeral = true;

    privateNetwork = true;
    enableTun = true;
    hostBridge = "br0";

    bindMounts = {
      ${defaultOutPathInContainer}.hostPath =
        config.age.secrets."oizys-sing-box-default-out".path;
      "/var/lib/sing-box/" = {
        hostPath = "/var/lib/sing-box/";
        isReadOnly = false;
      };
    };

    config = {
      lib,
      pkgs,
      ...
    }: let
      tunInterfaceName = "tun0";
      lanInterfaceName = "eth0";
      gatewayAddress = "10.31.0.2/16";
    in {
      networking = {
        useNetworkd = true;

        nftables.enable = true;
        firewall.enable = false;

        useHostResolvConf = lib.mkForce false;

        enableIPv6 = true;
      };

      services = {
        resolved.enable = false;
        sing-box = {
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
                interface_name = tunInterfaceName;
              }
            ];
            log = {
              level = "info";
              timestamp = true;
            };
            outbounds = [
              {
                # tag = "proxy";
                _secret = defaultOutPathInContainer;
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
      };

      systemd.network = {
        wait-online.enable = false;
        config.dhcpV4Config = {
          DUIDType = "vendor";
          DUIDRawData = "00:00:ab:11:2a:8f:c6:3e:89:37:a4:bc";
        };
        networks = {
          "40-${lanInterfaceName}" = {
            matchConfig.Name = lanInterfaceName;
            networkConfig = {
              DHCP = "no";
              Address = gatewayAddress;
              DefaultRouteOnDevice = true;
              IPv6AcceptRA = true;
              Gateway = "10.31.0.1";
            };
            dhcpV4Config.IAID = lib.fromHexString "0x93f4cce6";
          };
          "40-${tunInterfaceName}" = {
            matchConfig.Name = tunInterfaceName;
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
              iifname ${lanInterfaceName} oifname ${tunInterfaceName} masquerade
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
}

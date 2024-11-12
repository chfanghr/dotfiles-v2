{
  config,
  lib,
  ...
}: let
  inherit (lib) mkForce types mkOption;

  cfg = config.oizys.networking.vpnGatway;

  routingMark = 69;

  proxyFwMark = 1;
  proxyRouteTable = 100;

  tproxyPort = 8964;

  socksPort = 1087;
  httpPort = 1086;
  dnsPort = 5333;

  vpnServerConfigFilePathInContainer = "/tmp/vpn-server.json";
in {
  options.oizys.networking.vpnGatway = {
    ipv4.address = mkOption {
      type = types.str;
      default = "10.31.0.2";
    };
  };
  config = {
    age.secrets."oizys-sing-box-default-out".file = ../../secrets/oizys-sing-box-default-out.age;

    containers = {
      simLanHost2 = {
        privateNetwork = true;
        hostBridge = config.oizys.networking.lan.bridge.interface;
        ephemeral = true;
        autoStart = true;
        config = {pkgs, ...}: {
          networking = {
            useNetworkd = true;
            firewall.enable = true;
            useHostResolvConf = mkForce false;
            interfaces.eth0.ipv4.addresses = [
              {
                address = "10.31.0.3";
                prefixLength = 16;
              }
            ];
            defaultGateway = {
              interface = "eth0";
              address = cfg.ipv4.address;
              metric = 1;
            };
            nameservers = [
              cfg.ipv4.address
            ];
          };

          services.resolved.enable = true;

          environment.systemPackages = [
            pkgs.dig
            pkgs.ethtool
          ];

          system.stateVersion = "24.11";
        };
      };
      vpnGateway = {
        privateNetwork = true;
        hostBridge = config.oizys.networking.lan.bridge.interface;
        autoStart = true;
        bindMounts = {
          vpnServer = {
            hostPath = config.age.secrets."oizys-sing-box-default-out".path;
            mountPoint = vpnServerConfigFilePathInContainer;
          };
        };
        config = let
          lanInterface = "eth0";
        in {
          networking = {
            useNetworkd = true;
            firewall.enable = false;
            useHostResolvConf = mkForce false;
            enableIPv6 = false;
            interfaces.${lanInterface} = {
              useDHCP = true;
              ipv4.addresses = [
                {
                  prefixLength = config.oizys.networking.lan.ipv4.address.prefixLength;
                  address = cfg.ipv4.address;
                }
              ];
            };
            defaultGateway = {
              interface = lanInterface;
              address = config.oizys.networking.lan.ipv4.address.address;
            };
            nameservers = [
              config.oizys.networking.lan.ipv4.address.address
            ];
            localCommands = ''
              ip rule add fwmark ${toString proxyFwMark} lookup ${toString proxyRouteTable}
              ip route add local default dev ${lanInterface} table ${toString proxyRouteTable}
            '';
            nftables = {
              enable = true;
              ruleset = ''
                define RESERVED_IP = {
                  100.64.0.0/10,
                  127.0.0.0/8,
                  169.254.0.0/16,
                  172.16.0.0/12,
                  192.0.0.0/24,
                  224.0.0.0/4,
                  240.0.0.0/4,
                  255.255.255.255/32
                }

                define LAN_IP = {
                  10.31.0.0/16
                }

                table ip sing_box {
                  chain prerouting_dns {
                    type nat hook prerouting priority dstnat; policy accept;
                    ip daddr ${cfg.ipv4.address} meta l4proto { tcp, udp } th dport 53 redirect to :5333 comment "Forward all incoming packets targeting port 53 to port 5333 on which sing-box dns server is listening"
                  }

                  chain prerouting_tproxy {
                    type filter hook prerouting priority mangle; policy accept;
                    # iifname != ${lanInterface} return
                    fib daddr type local meta l4proto { tcp, udp } th dport ${toString tproxyPort} reject
                    fib daddr type local return
                    ip daddr $RESERVED_IP return
                    ip daddr $LAN_IP return
                    udp sport 41641 counter accept comment "Dont't proxy downstream Tailscale traffic"
                    udp dport 3478 counter accept comment "Don't proxy downstream STUN traffic"
                    meta l4proto tcp socket transparent 1 meta mark set ${toString proxyFwMark} accept
                    meta l4proto {tcp, udp} tproxy to :${toString tproxyPort} meta mark set ${toString proxyFwMark} accept
                  }
                }
              '';
            };
          };
          boot.kernel.sysctl = {
            "net.ipv4.conf.eth0.forwarding" = true;
          };
          services.sing-box = {
            enable = true;
            settings = {
              dns = {
                servers = [
                  {
                    tag = "bootstrap-dns";
                    address = "10.31.0.1";
                    detour = "direct-out";
                  }
                  {
                    tag = "system-dns";
                    address = "local";
                    detour = "direct-out";
                  }
                  {
                    tag = "cf-dns";
                    address = "https://1.1.1.1/dns-query";
                    strategy = "ipv4_only";
                    detour = "default-out";
                  }
                  {
                    tag = "block-dns";
                    address = "rcode://success";
                  }
                ];
                rules = [
                  {
                    outbound = "any";
                    server = "bootstrap-dns";
                  }
                ];
                final = "cf-dns";
                strategy = "ipv4_only";
              };
              inbounds = [
                {
                  type = "direct";
                  tag = "dns-in";
                  listen = "0.0.0.0";
                  listen_port = dnsPort;
                }
                {
                  type = "http";
                  tag = "http-in";
                  listen = "0.0.0.0";
                  listen_port = httpPort;
                  users = [];
                  sniff = true;
                  sniff_override_destination = false;
                }
                {
                  type = "socks";
                  tag = "socks-in";
                  listen = "0.0.0.0";
                  listen_port = socksPort;
                  users = [];
                  sniff = true;
                  sniff_override_destination = false;
                }
                {
                  type = "tproxy";
                  tag = "tproxy-in";
                  listen = "0.0.0.0";
                  listen_port = tproxyPort;
                  udp_fragment = true;
                  sniff = true;
                  sniff_override_destination = false;
                }
              ];
              outbounds = [
                {
                  # tag = "default-out";
                  _secret = vpnServerConfigFilePathInContainer;
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
                    protocol = "dns";
                    outbound = "dns-out";
                  }
                  {
                    inbound = "dns-in";
                    outbound = "dns-out";
                  }
                  {
                    ip_is_private = true;
                    outbound = "direct-out";
                  }
                  {
                    protocol = "bittorrent";
                    outbound = "direct-out";
                  }
                ];
                final = "default-out";
                auto_detect_interface = true;
                default_mark = routingMark;
              };
              experimental = {
                cache_file = {
                  enabled = true;
                };
              };
            };
          };

          system.stateVersion = "24.11";
        };
        additionalCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_SYS_ADMIN"
        ];
      };
    };
  };
}

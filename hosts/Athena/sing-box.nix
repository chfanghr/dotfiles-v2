{config, ...}: let
  tproxyPort = 8964;

  socksPort = 1087;
  httpPort = 1086;
  dnsPort = 5333;

  proxyFwMark = 1;
  proxyRouteTable = 100;

  routingMark = 69;

  lanInterface = "bond0";

  inherit (builtins) toString;
in {
  services.sing-box = {
    enable = true;
    settings = {
      dns = {
        servers = [
          {
            tag = "bootstrap-dns";
            address = "223.5.5.5";
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
          _secret = config.age.secrets."athena-sing-box-default-out".path;
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

  age.secrets."athena-sing-box-default-out".file = ../../secrets/athena-sing-box-default-out.age;

  networking = {
    firewall = {
      allowedTCPPorts = [socksPort httpPort dnsPort];
      allowedUDPPorts = [socksPort httpPort dnsPort];
    };
    localCommands = ''
      ip rule add fwmark ${toString proxyFwMark} lookup ${toString proxyRouteTable}
      ip route add local default dev ${lanInterface} table ${toString proxyRouteTable}
    '';
    nftables.ruleset = ''
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
        10.41.0.0/16
      }

      table ip sing_box {
        chain prerouting_dns {
          type nat hook prerouting priority dstnat; policy accept;
          meta l4proto { tcp, udp } th dport 53 redirect to :5333 comment "Forward all incoming packets targeting port 53 to port 5333 on which sing-box dns server is listening"
        }

        chain prerouting_tproxy {
          type filter hook prerouting priority mangle; policy accept;
          # iifname != ${lanInterface} return
          fib daddr type local meta l4proto { tcp, udp } th dport ${toString tproxyPort} reject
          fib daddr type local return
          ip daddr $RESERVED_IP return
          ip daddr $LAN_IP return
          udp sport 41641 counter accept comment "Dont' proxy downstream Tailscale traffic"
          udp dport 3478 counter accept comment "Don't proxy downstream STUN traffic"
          meta l4proto tcp socket transparent 1 meta mark set ${toString proxyFwMark} accept
          meta l4proto {tcp, udp} tproxy to :${toString tproxyPort} meta mark set ${toString proxyFwMark} accept
        }
      }
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
  };
}

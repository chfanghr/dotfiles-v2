{config, ...}: let
  socksPort = 1087;
  httpPort = 1086;
  dnsPort = 5333;

  routingMark = 69;
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
        # {
        #   type = "tproxy";
        #   tag = "tproxy-in";
        #   listen = "0.0.0.0";
        #   listen_port = tproxyPort;
        #   udp_fragment = true;
        #   sniff = true;
        #   sniff_override_destination = false;
        # }
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

  systemd.services.sing-box.restartTriggers = [config.age.secrets."athena-sing-box-default-out".file];

  age.secrets."athena-sing-box-default-out".file = ../../secrets/athena-sing-box-default-out.age;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
  };

  networking.firewall.interfaces.br0.allowedTCPPorts = [
    socksPort
    httpPort
  ];
}

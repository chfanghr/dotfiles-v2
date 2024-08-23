{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption mkEnableOption mkMerge mkIf attrValues mergeAttrsList;
  inherit (builtins) toString map;

  cfg = config.oizys.networking;

  staticAddressType = types.submodule ({config, ...}: {
    options = {
      address = mkOption {
        type = types.str;
      };

      prefixLength = mkOption {
        type = types.ints.between 8 32;
      };

      networkdAddress = mkOption {
        type = types.str;
        default = "${config.address}/${toString config.prefixLength}";
        readOnly = true;
      };
    };
  });

  staticLeaseType = types.submodule {
    options = {
      address = mkOption {
        type = types.str;
      };

      macAddress = mkOption {
        type = types.str;
      };
    };
  };
in {
  options.oizys.networking = {
    mgmt = {
      enable =
        mkEnableOption "Management port"
        // {
          default = true;
        };

      interface = mkOption {
        type = types.str;
        default = "enp0s20f0u4";
      };

      address = mkOption {
        type = types.nullOr staticAddressType;
        default = null;
      };

      networkdProfile = mkOption {
        type = types.str;
        default = "10-mgmt";
        readOnly = true;
      };
    };

    wan = {
      interface = mkOption {
        type = types.str;
        default = "enp1s0";
      };

      mode = mkOption {
        type = types.enum ["dhcp" "pppoe"];
        default = "dhcp";
      };

      pppoe = {
        username = mkOption {
          type = types.str;
        };

        passwordFile = mkOption {
          type = types.path;
        };

        unitNumber = mkOption {
          type = types.ints.unsigned;
          default = 0;
        };

        interface = mkOption {
          type = types.str;
          default = "ppp${toString cfg.wan.pppoe.unitNumber}";
          readOnly = true;
        };

        peerName = mkOption {
          type = types.str;
          default = "main";
          readOnly = true;
        };

        networkdProfile = mkOption {
          type = types.str;
          default = "10-wan-pppoe";
          readOnly = true;
        };
      };

      finalInterface = mkOption {
        type = types.str;
        default =
          if cfg.wan.mode == "dhcp"
          then cfg.wan.interface
          else cfg.wan.pppoe.interface;
        readOnly = true;
      };

      networkdProfile = mkOption {
        type = types.str;
        default = "10-wan";
        readOnly = true;
      };
    };

    lan = {
      interfaces = mkOption {
        type = types.nonEmptyListOf types.str;
        default = ["enp3s0" "enp4s0"];
      };

      ipv4 = {
        address = mkOption {
          type = staticAddressType;
          default = {
            address = "10.31.0.1";
            prefixLength = 16;
          };
        };

        staticLeases = mkOption {
          type = types.attrsOf staticLeaseType;
          default = {};
        };
      };

      bridge = {
        interface = mkOption {
          type = types.str;
          default = "br-lan";
          readOnly = true;
        };

        networkdProfile = mkOption {
          type = types.str;
          default = "10-br-lan";
          readOnly = true;
        };

        dummy = {
          interface = mkOption {
            type = types.str;
            default = "dummy0";
            readOnly = true;
          };

          networkdProfile = mkOption {
            type = types.str;
            default = "10-dummy0";
            readOnly = true;
          };
        };
      };

      dnsServer = {
        webuUIPort = mkOption {
          type = types.port;
          default = 3000;
          readOnly = true;
        };

        upstreams = mkOption {
          type = types.listOf types.str;
          default = [
            "tls://dns-unfiltered.adguard.com"
            "9.9.9.9"
            "149.112.112.112"
            "1.1.1.1"
          ];
        };

        fallbacks = mkOption {
          type = types.listOf types.str;
          default = [
            "223.5.5.5"
            "114.114.114.114"
          ];
        };

        rules = mkOption {
          type = types.listOf types.str;
          default = [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
          ];
        };
      };

      # TODO(chfanghr): IPv6
    };
  };

  config = mkMerge [
    {
      networking = {
        useNetworkd = true;
        useDHCP = false;
        firewall.enable = false;
        nat.enable = false;
        nftables = {
          enable = true;
          # preCheckRuleset = "sed 's/.*devices.*/devices = { lo }/g' -i ruleset.conf";
        };
        nameservers = ["223.5.5.5"];
      };

      services.resolved.enable = true;

      systemd.network.wait-online.anyInterface = true;

      boot.initrd.availableKernelModules = ["bridge"];

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv4.conf.all.forwarding" = 1;
      };
    }
    (
      # Mgmt
      mkIf cfg.mgmt.enable (
        mkMerge [
          {
            systemd.network.networks.${cfg.mgmt.networkdProfile} = {
              networkConfig.Description = "management port";
              matchConfig.Name = cfg.mgmt.interface;
              linkConfig.RequiredForOnline = "no";
            };
          }
          {
            systemd.network.networks.${cfg.mgmt.networkdProfile} =
              if cfg.mgmt.address == null
              then {
                networkConfig = {
                  DHCP = "ipv4";
                  DefaultRouteOnDevice = "no";
                };
                dhcpV4Config = {
                  UseRoutes = "no";
                  UseGateway = "no";
                  UseDNS = "no";
                };
              }
              else {
                networkConfig.DHCP = "no";
                address = [cfg.mgmt.address.networkdAddress];
              };
          }
        ]
      )
    )
    {
      # Lan
      systemd.network = {
        netdevs = {
          ${cfg.lan.bridge.networkdProfile} = {
            netdevConfig = {
              Kind = "bridge";
              Name = cfg.lan.bridge.interface;
            };
            bridgeConfig = {
              STP = "yes";
            };
          };
          ${cfg.lan.bridge.dummy.networkdProfile} = {
            netdevConfig = {
              Kind = "dummy";
              Name = cfg.lan.bridge.dummy.interface;
            };
          };
        };
        networks =
          {
            ${cfg.lan.bridge.networkdProfile} = {
              matchConfig.Name = cfg.lan.bridge.interface;
              networkConfig = {
                Description = "lan bridge";
                DHCP = "no";
                ConfigureWithoutCarrier = "yes";
                EmitLLDP = "yes";
                DHCPServer = "yes";
                IPv4Forwarding = "yes";
              };
              bridgeConfig = {
                AllowPortToBeRoot = "yes";
              };
              address = [cfg.lan.ipv4.address.networkdAddress];
              dhcpServerConfig = {
                PoolOffset = 10;
                EmitDNS = "yes";
                DNS = cfg.lan.ipv4.address.address;
                EmitRouter = "yes";
                Router = cfg.lan.ipv4.address.address;
              };
              dhcpServerStaticLeases = map (lease: {
                dhcpServerStaticLeaseConfig = {
                  Address = lease.address;
                  MACAddress = lease.macAddress;
                };
              }) (attrValues cfg.lan.ipv4.staticLeases);
            };
            ${cfg.lan.bridge.dummy.networkdProfile} = {
              matchConfig.Name = cfg.lan.bridge.dummy.interface;
              networkConfig = {
                Description = "dummy slave of lan bridge to keep it UP";
                Bridge = cfg.lan.bridge.interface;
              };
            };
          }
          // mergeAttrsList (map (interface: {
              "10-${interface}" = {
                matchConfig.Name = interface;
                networkConfig = {
                  Description = "slave of lan bridge";
                  Bridge = cfg.lan.bridge.interface;
                  ConfigureWithoutCarrier = "yes";
                };
                linkConfig.RequiredForOnline = "enslaved";
              };
            })
            cfg.lan.interfaces);
      };
      services.adguardhome = {
        enable = true;
        host = "127.0.0.1";
        port = cfg.lan.dnsServer.webuUIPort;
        settings = {
          dns = {
            bind_hosts = [
              cfg.lan.ipv4.address.address
            ];
            upstream_dns = cfg.lan.dnsServer.upstreams;
            fallback_dns = cfg.lan.dnsServer.fallbacks;
          };
          filtering = {
            protection_enabled = true;
            filtering_enabled = true;
          };
          filters =
            map (url: {
              enabled = true;
              inherit url;
            })
            cfg.lan.dnsServer.rules;
        };
      };
    }
    ( # Wan
      mkMerge [
        {
          systemd.network.networks.${cfg.wan.networkdProfile} = {
            matchConfig.Name = cfg.wan.interface;
            networkConfig = {
              Description = "wan port";
              IPv4Forwarding = "yes";
            };
            linkConfig.RequiredForOnline = "no";
          };
        }
        (mkIf (cfg.wan.mode == "dhcp") {
          systemd.network.networks.${cfg.wan.networkdProfile}.networkConfig.DHCP = "ipv4";
        })
        (mkIf (cfg.wan.mode == "pppoe") {
          systemd.network.networks.${cfg.wan.networkdProfile}.linkConfig.ActivationPolicy = "always-up";

          systemd.network.networks.${cfg.wan.pppoe.networkdProfile} = {
            matchConfig.Name = cfg.wan.pppoe.interface;
            networkConfig = {
              Description = "wan pppoe interface";
              IPv4Forwarding = "yes";
            };
            linkConfig = {
              RequiredForOnline = "no";
              Unmanaged = true;
            };
          };

          systemd.services.setup-pap-secrets = {
            wantedBy = ["multi-user.target"];
            script = ''
              mkdir -p /etc/ppp
              echo -ne "${cfg.wan.pppoe.username} * $(cat "${cfg.wan.pppoe.passwordFile}")" > /etc/ppp/pap-secrets
            '';
            serviceConfig = {
              Type = "oneshot";
              Restart = "on-failure";
              UMask = "0077";
            };
            after = ["network.target"];
            before = ["pppd-${cfg.wan.pppoe.peerName}.service"];
          };

          services.pppd = {
            enable = true;
            peers = {
              ${cfg.wan.pppoe.peerName} = {
                autostart = true;
                enable = true;
                config = ''
                  plugin pppoe.so ${cfg.wan.interface}

                  name "${cfg.wan.pppoe.username}"

                  unit ${toString cfg.wan.pppoe.unitNumber}

                  persist
                  maxfail 0
                  holdoff 5

                  noipdefault
                  defaultroute
                '';
              };
            };
          };
        })
      ]
    )
    {
      networking.nftables.tables = {
        filter = {
          family = "inet";
          content = ''
            # flowtable f {
            #   hook ingress priority 0;
            #   devices = { "${cfg.lan.bridge.interface}", "${cfg.wan.finalInterface}" };
            # }

            chain input {
                type filter hook input priority filter; policy drop;

                iifname "lo" accept comment "Accept everything from loopback interface"
                iifname "tailscale0" accept comment "Allow tailscale to access the router"
                iifname "${cfg.mgmt.interface}" accept comment "Allow management network to access the router"
                iifname "${cfg.lan.bridge.interface}" accept comment "Allow local network to access the router"

                iifname "${cfg.wan.finalInterface}" ct state { established, related } accept comment "Allow established traffic"
                iifname "${cfg.wan.finalInterface}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
                iifname "${cfg.wan.finalInterface}" counter drop comment "Drop all other unsolicited traffic from wan"
            }

            chain forward {
                type filter hook forward priority filter; policy drop;

                # ip protocol { tcp, udp } flow offload @f

                iifname "tailscale0" accept comment "Let tailscale handle the traffic"

                iifname "${cfg.lan.bridge.interface}" oifname "${cfg.wan.finalInterface}" accept comment "Allow trusted LAN to WAN"
                iifname "${cfg.wan.finalInterface}" oifname "${cfg.lan.bridge.interface}" ct state { established, related } accept comment "Allow established back to LANs"
            }
          '';
        };
        nat = {
          family = "ip";
          content = ''
            chain postrouting {
              type nat hook postrouting priority filter; policy accept;
              # meta nftrace set 1
              oifname "${cfg.wan.finalInterface}" counter masquerade
            }
          '';
        };
      };
    }
    {
      services.miniupnpd = {
        enable = true;
        upnp = true;
        natpmp = true;
        externalInterface = cfg.wan.finalInterface;
        internalIPs = [cfg.lan.bridge.interface];
      };
    }
  ];
}

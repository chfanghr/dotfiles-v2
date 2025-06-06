{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) types mkOption mkForce;
  inherit (builtins) toString;

  cfg = config.athena.networking;

  pkgsUnstable = import inputs.nixpkgs-unstable {inherit (pkgs.stdenv) system;};
in {
  options.athena.networking = {
    mlag = {
      interface = mkOption {type = types.str;};
      netdevProfile = mkOption {type = types.str;};
      networkProfile = mkOption {type = types.str;};

      slave = {
        interfaces = mkOption {type = types.listOf types.str;};
        networkProfile = mkOption {type = types.str;};
      };
    };

    lan = {
      interface = mkOption {type = types.str;};
      networkProfile = mkOption {type = types.str;};
      ipv4 = {
        address = {
          address = mkOption {type = types.str;};
          prefixLength = mkOption {type = types.ints.unsigned;};
        };
        defaultGateway = mkOption {type = types.str;};
      };
    };

    lanBridge = {
      interface = mkOption {type = types.str;};
      netdevProfile = mkOption {type = types.str;};
      networkProfile = mkOption {type = types.str;};
    };

    mgmt = {
      interface = mkOption {type = types.str;};
      networkProfile = mkOption {type = types.str;};

      ipv4.address = {
        address = mkOption {type = types.str;};
        prefixLength = mkOption {type = types.ints.unsigned;};
      };
    };
  };

  config = {
    athena.networking = {
      mlag = {
        interface = "bond0";
        netdevProfile = "10-bond0";
        networkProfile = "10-bond0";
        slave = {
          interfaces = ["enp1s0" "enp2s0" "enp3s0"];
          networkProfile = "10-bond0-slaves";
        };
      };

      lan = {
        interface = "enp4s0";
        networkProfile = "10-enp4s0";
      };

      lanBridge = {
        interface = "br0";
        netdevProfile = "10-br0";
        networkProfile = "10-br0";
      };

      mgmt = {
        interface = "enp6s0";
        networkProfile = "10-enp6s0";
        ipv4.address = {
          address = "192.168.255.3";
          prefixLength = 24;
        };
      };
    };

    networking = {
      enableIPv6 = true;
      useNetworkd = true;
      firewall.enable = true;
      nftables.enable = true;
      useDHCP = false;
      # WORKAROUND: use these two inside gfw
      nameservers = mkForce ["223.5.5.5" "1.1.1.1"];
    };

    systemd = {
      network = {
        wait-online.ignoredInterfaces = [
          cfg.mgmt.interface
        ];

        netdevs = {
          ${cfg.mlag.netdevProfile} = {
            netdevConfig = {
              Kind = "bond";
              Name = cfg.mlag.interface;
            };
            bondConfig.Mode = "802.3ad";
          };

          ${cfg.lanBridge.netdevProfile} = {
            netdevConfig = {
              Kind = "bridge";
              Name = cfg.lanBridge.interface;
            };
          };
        };

        networks = {
          ${cfg.mlag.slave.networkProfile} = {
            matchConfig.Name = cfg.mlag.slave.interfaces;
            networkConfig = {
              Bond = cfg.mlag.interface;
              LLDP = true;
              EmitLLDP = true;
            };
          };

          ${cfg.mlag.networkProfile} = {
            matchConfig.Name = cfg.mlag.interface;
            networkConfig.Bridge = cfg.lanBridge.interface;
          };

          ${cfg.lan.networkProfile} = {
            matchConfig.Name = cfg.lan.interface;
            networkConfig = {
              IPv6PrivacyExtensions = "kernel";
              IPv6AcceptRA = true;
              DHCP = "ipv4";
            };
          };

          ${cfg.lanBridge.networkProfile} = {
            matchConfig.Name = cfg.lanBridge.interface;
          };

          ${cfg.mgmt.networkProfile} = {
            matchConfig.Name = cfg.mgmt.interface;
            networkConfig.Address = with cfg.mgmt.ipv4.address; "${address}/${toString prefixLength}";
          };

          "40-ignore-veths" = {
            networkConfig.Description = "Don't configure any veth interfaces by default";
            matchConfig = {
              Name = "ve-*";
              Kind = "veth";
            };
            linkConfig = {
              Unmanaged = true;
              ActivationPolicy = "manual";
            };
          };
        };
      };
    };

    environment.defaultPackages = [
      pkgs.ethtool
      pkgs.dig
      pkgs.minicom
    ];

    services = {
      tailscale = {
        package = pkgsUnstable.tailscale;

        useRoutingFeatures = lib.mkForce "both";

        extraSetFlags = ["--advertise-routes" "10.41.0.0/16"];
      };

      iperf3 = {
        enable = true;
        openFirewall = true;
      };
    };

    boot = {
      kernelModules = ["tcp_bbr"];
      kernel.sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
      };
    };

    specialisation.recovery.configuration = {
      networking.interfaces.enp5s0.useDHCP = true;
    };
  };
}

{
  lib,
  config,
  ...
}: {
  options.persephone.networking.useStaticIP =
    lib.mkEnableOption "use static ip"
    // {
      default = true;
    };

  imports = [
    {
      networking = {
        hostName = "Persephone";
        hostId = "9ce62f33"; # Required by zfs

        useDHCP = false;

        useNetworkd = true;

        bonds.bond0 = {
          interfaces = ["enp195s0f0" "enp195s0f1"];
          driverOptions = {
            mode = "802.3ad";
          };
        };

        interfaces = {
          enp33s0f3 = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = "192.168.255.4";
                prefixLength = 24;
              }
            ];
          };
        };

        nat = {
          enable = true;
          internalInterfaces = ["ve-+"];
          externalInterface = "bond0";
          enableIPv6 = true;
        };

        nftables.enable = true;

        firewall.enable = true;

        nameservers = lib.mkForce ["223.5.5.5"];
      };

      systemd.network.networks = {
        "40-bond0".networkConfig = {
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = "kernel";
        };
        "40-veth" = {
          matchConfig = {
            Name = "ve-*";
            Kind = "veth";
          };
          linkConfig.Unmanaged = false;
        };
        "40-enp33s0f0" = {
          matchConfig.Name = "enp33s0f0";
          linkConfig.Unmanaged = false;
        };
      };

      systemd.services.tailscaled.serviceConfig.UnsetEnvironment = ["http_proxy" "https_proxy" "all_proxy"];

      boot = {
        kernelModules = ["tcp_bbr"];

        kernel.sysctl = {
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "fq";
        };
      };

      services = {
        iperf3 = {
          enable = true;
          openFirewall = true;
        };
        lldpd = {
          enable = true;
          extraArgs = ["-I" "bond0"];
        };
        tailscale-traefik.enable = true;
      };
    }
    (lib.mkIf config.persephone.networking.useStaticIP {
      networking = {
        interfaces.bond0 = {
          ipv4.addresses = [
            {
              address = "10.41.255.234";
              prefixLength = 16;
            }
          ];
        };
        defaultGateway = {
          address = config.dotfiles.shared.networking.home.router.address;
          interface = "bond0";
        };
      };
    })
    {
      specialisation.useDHCP.configuration = {
        persephone.networking.useStaticIP = false;
        networking.interfaces.bond0.useDHCP = true;
      };
    }
  ];
}

{
  lib,
  inputs,
  ...
}: {
  imports = [
    ./boot.nix
    ./cardano.nix
    ./file-systems.nix
    ./hercules-ci-agent.nix
    ./minecraft.nix
    ./nfs.nix
    ./nix.nix
    ./security.nix
    ../../modules/nixos/common
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "Demeter";

  services.hardware.openrgb.motherboard = "amd";

  dotfiles = {
    shared.props = {
      purposes = {
        work = true;
        graphical.desktop = lib.mkDefault true;
      };
      networking.home = {
        onLanNetwork = true;
        proxy.useGateway = true;
      };
    };
    nixos = {
      props = {
        hardware = {
          audio = true;
          bluetooth = {
            enable = true;
            blueman = true;
          };
          cpu.amd = true;
          gpu.amd.enable = true;
          emulation = true;
          rgb = true;
          vmHost = true;
        };
        nix.roles.builder = true;
        users.guests = {
          thungghuan = true;
          robertchen = true;
        };
        ociHost = true;
      };
      networking.lanInterfaces = ["enp81s0"];
    };
  };

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };

    tailscale-traefik.enable = true;
  };

  home-manager.users.fanghr = {
    dotfiles.hm.graphical.desktop.hyprland.extraConfig = ''
      monitor=DP-1,3840x2160@120,0x0,2
    '';
    programs.git.signing = {
      key = "0x06DA3273BC714AE7";
      signByDefault = true;
    };
  };

  users.users = {
    fanghr = {
      hashedPassword = "$y$j9T$q3G6zE9QU2YXOxG2wLqCW1$DDWbED5h2fXtgNev2MtNhkNXFPzayP7w8O9HCLlx3Y5";
      extraGroups = ["cardano-node" "minecraft"];
    };
    robertchen.extraGroups = ["minecraft"];
    szg251 = {
      isNormalUser = true;
      createHome = true;
      extraGroups = ["cardano-node" "docker"];
      home = "/home/szg251";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8SiZHctbdcQhuteXYuO1Yw4XgM/fO3QDTYKyyA4UKj"
      ];
    };
    huang825172 = {
      isNormalUser = true;
      createHome = true;
      home = "/home/huang825172";
      extraGroups = ["minecraft"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAazJ0pGWavJEs9ndG5Ki4Ww8ninGwOBo2sZhPq2Et1f"
      ];
    };
  };

  programs.mosh.enable = true;

  boot = {
    kernelModules = ["tcp_bbr"];

    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };

  networking = {
    enableIPv6 = true;
    bonds.bond0 = {
      interfaces = ["enp6s0f0" "enp6s0f1"];
      driverOptions = {
        mode = "802.3ad";
      };
    };
    interfaces = {
      bond0.useDHCP = false;
      eno1 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.255.2";
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
  };

  systemd.network.networks."40-bond0".networkConfig.IPv6AcceptRA = true;

  # systemd.network.networks."40-eno1" = {
  #   matchConfig.Name = "eno1";
  #   dhcpV4Config.RouteMetric = 1025;
  #   networkConfig.DHCP = "ipv4";
  # };

  services.lldpd.enable = true;

  demeter.minecraft.enable = lib.mkDefault true;

  specialisation = {
    debug.configuration = {
      dotfiles.shared.props.networking.home.proxy.useGateway = lib.mkForce false;
      boot.plymouth.enable = false;
      dotfiles.shared.props.purposes.graphical.desktop = false;
      demeter.minecraft.enable = false;
    };
    noProxy.configuration = {
      dotfiles.shared.props.networking.home.proxy.useGateway = lib.mkForce false;
      networking.proxy = {
        default = lib.mkForce null;
        httpProxy = lib.mkForce null;
        httpsProxy = lib.mkForce null;
        noProxy = "127.0.0.1,localhost,*.local,*.snow-dace.ts.net";
      };
    };
    staticIP.configuration = {
      dotfiles.shared.props.networking.home.proxy.useGateway = lib.mkForce false;
      networking.proxy = {
        default = lib.mkForce null;
        httpProxy = lib.mkForce null;
        httpsProxy = lib.mkForce null;
        noProxy = "127.0.0.1,localhost,*.local,*.snow-dace.ts.net";
      };
      networking = {
        interfaces.bond0 = {
          useDHCP = lib.mkForce false;
          ipv4.addresses = [
            {
              address = "10.41.0.246";
              prefixLength = 16;
            }
          ];
        };
        defaultGateway = {
          address = "10.41.255.251";
          interface = "bond0";
        };
        nameservers = lib.mkBefore ["10.41.255.251"];
      };
    };
  };
}

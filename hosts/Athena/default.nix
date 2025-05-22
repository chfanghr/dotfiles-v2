{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  bondName = "bond0";
  inherit (lib) mkForce;

  mkEnableInterfaceFeatureScript = interface: feature:
    pkgs.writeShellApplication {
      name = "enable-${feature}-for-${interface}";

      runtimeInputs = [pkgs.ethtool];

      text = ''
        echo "enabling ${feature} for ${interface}"

        ( (ethtool --show-features ${interface} | grep ${feature}) \
          && ethtool -K ${interface} ${feature} on ) \
          || true
      '';
    };
in {
  imports = [
    ./disko.nix
    ./sing-box.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
  ];

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    users = {
      rootAccess = true;
      fanghr.disableHm = true;
    };
    hardware = {
      cpu.intel = true;
      # vmHost = true;
    };
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users = {
    fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";
    root.hashedPassword = "$y$j9T$LclEAQG.FK8eoV2.mc6ku1$dDc7MUikq2gi7Jpbo4AeQsnkdUjEFsfJ0XbhMY3yedA";
  };

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "igc"
    ];
    kernelModules = ["tcp_bbr"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };

  nix.gc.options = "--delete-older-than +8";

  networking = {
    hostName = "Athena";

    useNetworkd = true;

    nftables.enable = true;

    bonds.${bondName} = {
      interfaces = ["enp1s0" "enp2s0" "enp3s0"];
      driverOptions.mode = "802.3ad";
    };
    interfaces = {
      ${bondName}.ipv4.addresses = [
        {
          address = config.dotfiles.shared.networking.home.gateway.address;
          prefixLength = 16;
        }
      ];
      enp6s0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.255.3";
            prefixLength = 24;
          }
        ];
      };
    };
    defaultGateway = {
      interface = bondName;
      address = config.dotfiles.shared.networking.home.router.address;
    };

    firewall.enable = false;

    localCommands = ''
      ${lib.getExe (mkEnableInterfaceFeatureScript "bond0" "rx-udp-gro-forwarding")}
      ${lib.getExe (mkEnableInterfaceFeatureScript "enp1s0" "rx-udp-gro-forwarding")}
      ${lib.getExe (mkEnableInterfaceFeatureScript "enp2s0" "rx-udp-gro-forwarding")}
    '';

    enableIPv6 = false;
  };

  environment.defaultPackages = [
    pkgs.zellij
    pkgs.minicom
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  services = {
    tailscale.useRoutingFeatures = mkForce "both";
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
  };
}

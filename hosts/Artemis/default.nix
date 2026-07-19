{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./disko.nix
    ./hardware.nix
    ./networking.nix
    ./samba.nix
    ./tank.nix
    ./telemetry.nix
    ./vpn-gateway.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
  ];

  dotfiles = {
    shared.props.locationName = "cn-2";
    nixos.props = {
      nix.roles.consumer = true;
      users.guests.fry = true;
      hardware = {
        cpu.intel = true;
        vmHost = true;
      };
      ociHost = true;
      services.prometheus.pushToCollector = false;
    };
  };

  users.users.fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";

  networking.hostName = "Artemis";

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
  };

  services.prometheus = {
    enable = lib.mkForce false;
    exporters = {
      node.enable = true;
      systemd.enable = true;
      smartctl.enable = true;
      zfs.enable = true;
    };
  };
}

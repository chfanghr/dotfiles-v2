{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./disko.nix
    ./hardware.nix
    ./networking.nix
    ./samba.nix
    ./tank.nix
    ./vpn-gateway.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
  ];

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    users.guests.fry = true;
    hardware = {
      cpu.intel = true;
      vmHost = true;
    };
    ociHost = true;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";

  networking.hostName = "Artemis";

  nixpkgs.localSystem.system = "x86_64-linux";

  environment.defaultPackages = [
    pkgs.zellij
  ];

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
      node = {
        enable = true;
        listenAddress = lib.mkForce "0.0.0.0";
      };
      systemd.enable = true;
      smartctl.enable = true;
      zfs.enable = true;
    };
  };
}

{
  modulesPath,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix
  ];

  boot.loader = {
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    timeout = 30;
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
    };
    fail2ban.enable = true;

    tailscale.enable = true;
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGAwQMMyMA0OVAMDMVKf84M12JKviI31i2d5HIX9Qwy fanghr@Dioscuri.local"
  ];

  networking = {
    hostName = "Dione";
    enableIPv6 = true;
    useNetworkd = true;
    nftables.enable = true;
    interfaces.enp1s0 = {
      useDHCP = true;
      ipv6.addresses = [
        {
          address = "2a01:4f8:1c19:df04::1";
          prefixLength = 64;
        }
      ];
    };
    firewall.enable = true;
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  hardware.facter = {
    enable = true;
    reportPath = ./facter.json;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "26.05";
}

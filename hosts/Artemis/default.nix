{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disko.nix
    ./hardware.nix
    ./samba.nix
    ./tank.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    users = {
      fanghr.disableHm = true;
      guests.fry = true;
    };
    hardware.cpu.intel = true;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";

  networking = {
    hostName = "Artemis";
    useNetworkd = true;
    nftables.enable = true;
  };

  environment.defaultPackages = [
    pkgs.zellij
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
  };
}

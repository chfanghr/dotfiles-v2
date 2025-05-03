{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./boot.nix
    ./calibre.nix
    ./fah.nix
    ./kerberos.nix
    ./migration.nix
    ./minidlna.nix
    ./networking.nix
    ./nfs.nix
    ./prometheus.nix
    ./qbittorrent.nix
    ./samba.nix
    ./security.nix
    ./tank.nix
    ./traefik.nix
    ./vault.nix
    ../../modules/nixos/common
    inputs.agenix.nixosModules.default
  ];

  dotfiles = {
    shared.props = {
      networking.home = {
        onLanNetwork = true;
        proxy.useGateway = true;
      };
    };
    nixos.props = {
      hardware = {
        cpu.amd = true;
        emulation = true;
        vmHost = true;
      };
      nix.roles = {
        builder = true;
        consumer = true;
      };
      ociHost = true;
    };
  };

  users.users.fanghr.hashedPassword = "$y$j9T$XaW9wwzHGPQ7kqLde615M0$jUxI2Jsv7KKq4xBZQZfnxjr1txKlBN7lDk/RKk0BclA";

  environment.systemPackages = [
    pkgs.megacli
    pkgs.minicom
    config.boot.kernelPackages.turbostat
  ];

  nixpkgs.config.allowUnfree = true;

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}

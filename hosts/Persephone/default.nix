{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./boot.nix
    ./calibre.nix
    ./cardano.nix
    ./fah.nix
    ./grafana.nix
    ./kerberos.nix
    ./loki.nix
    ./migration.nix
    ./minidlna.nix
    ./networking.nix
    ./nfs.nix
    ./nix.nix
    ./prometheus.nix
    ./qbittorrent.nix
    ./samba.nix
    ./tank.nix
    ./vault.nix
    ../../modules/nixos/common
    inputs.agenix.nixosModules.default
  ];

  dotfiles = {
    shared.props = {
      networking.home = {
        onLanNetwork = true;
      };
    };
    nixos = {
      props = {
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
      nix.builderPrivateKeyAgeSecret = ../../secrets/persephone-nix-cache-key.age;
    };
  };

  users.users.fanghr.hashedPassword = "$y$j9T$XaW9wwzHGPQ7kqLde615M0$jUxI2Jsv7KKq4xBZQZfnxjr1txKlBN7lDk/RKk0BclA";

  environment.systemPackages = [
    pkgs.megacli
    pkgs.minicom
    config.boot.kernelPackages.turbostat
  ];

  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}

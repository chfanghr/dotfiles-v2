{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./authelia.nix
    ./boot.nix
    ./darwin-backups.nix
    ./disko-config.nix
    ./grafana.nix
    ./impermanence.nix
    ./networking.nix
    ./postfix.nix
    ./qbittorrent.nix
    ./reverse-proxy.nix
    ./samba.nix
    ./yac.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.impermanence.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  networking.hostName = "Apollo";

  hardware.facter.reportPath = ./facter.json;

  dotfiles = {
    shared.props.locationName = "sg";
    nixos.props = {
      users.rootAccess = true;
      nix.roles.consumer = true;
      hardware = {
        cpu.intel = true;
        gpu.intel = true;
        vmHost = true;
      };
      services.prometheus.pushToCollector = false;
    };
  };

  users.users = {
    fanghr.hashedPassword = "$y$j9T$9/lN9oIe6ucVOI45U4Nxk0$KTFiL2Rm5mtxj/O7Rsm951NT7ANeDmRAshr4yapZQM/";
    root.hashedPassword = "$y$j9T$KyDUS1v19hdVfQWf68CPf0$zMGwak.72oGWX80IsM5JI8GN1ZxS712NercbXME0Xu9";
  };

  environment.defaultPackages = [
    pkgs.smartmontools
  ];
}

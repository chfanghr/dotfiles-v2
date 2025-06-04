{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./impermanence.nix
    ./networking.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.impermanence.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  networking.hostName = "Apollo";

  time.timeZone = "Asia/Singapore";

  facter.reportPath = ./facter.json;

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    hardware = {
      cpu.intel = true;
      gpu.intel = true;
      vmHost = true;
    };
  };

  users.users.fanghr.hashedPassword = "$y$j9T$9/lN9oIe6ucVOI45U4Nxk0$KTFiL2Rm5mtxj/O7Rsm951NT7ANeDmRAshr4yapZQM/";

  environment.defaultPackages = [
    pkgs.sbctl
  ];
}

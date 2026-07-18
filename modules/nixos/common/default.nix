{inputs, ...}: {
  imports = [
    ./container
    ./desktop
    ./hardware
    ./nix
    ./services
    ./users
    ./agenix.nix
    ./constants.nix
    ./gaming.nix
    ./kernel.nix
    ./misc.nix
    ./networking.nix
    ./podman.nix
    ./upgrade-diff.nix
    ../../shared
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.default
  ];

  home-manager.extraSpecialArgs = {inherit inputs;};

  system.stateVersion = "24.05";
}

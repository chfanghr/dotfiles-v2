{inputs, ...}: {
  imports = [
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
  ];

  home-manager.extraSpecialArgs = {inherit inputs;};

  system.stateVersion = "24.05";
}

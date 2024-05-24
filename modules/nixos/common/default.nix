{inputs, ...}: {
  imports = [
    ./avahi.nix
    ./clamav.nix
    ./bluetooth.nix
    ./hardware.nix
    ./misc.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./pipewire.nix
    ./podman.nix
    ./rgb.nix
    ./security.nix
    ./tailscale.nix
    ./vscode.nix
    ./fanghr.nix
    ./graphical.nix
    ./gaming.nix
    ./time.nix
    ./dotfiles.nix
    ./greetd.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.extraSpecialArgs = {inherit inputs;};

  system.stateVersion = "24.05";
}

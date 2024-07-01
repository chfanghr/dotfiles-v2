{inputs, ...}: {
  imports = [
    inputs.cardano-nix.nixosModules.default
  ];

  cardano = {
    enable = true;
    network = "preprod";
    http.enable = false;
  };
}

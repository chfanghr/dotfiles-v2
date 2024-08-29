{inputs, ...}: {
  imports = [
    inputs.cardano-nix.nixosModules.default
  ];

  cardano = {
    enable = true;
    network = "preprod";
    http.enable = false;
    db-sync.enable = false;
    blockfrost.enable = false;
    oura.enable = false;
  };
}

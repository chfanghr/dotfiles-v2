{inputs, ...}: {
  imports = [
    inputs.cardano-nix.nixosModules.default
  ];

  cardano = {
    network = "preprod";
    node.enable = true;
    ogmios.enable = true;
    http.enable = false;
    db-sync.enable = true;
    blockfrost.enable = false;
    oura.enable = false;
  };
}

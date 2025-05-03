{
  inputs,
  lib,
  ...
}: {
  containers.cardano-node-preprod = {
    privateNetwork = true;
    config = {
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

      networking.useHostResolvConf = lib.mkForce false;

      services.resolved.enable = true;

      system.stateVersion = "24.11";
    };
  };
}

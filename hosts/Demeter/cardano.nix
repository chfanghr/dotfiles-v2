{
  inputs,
  lib,
  ...
}: {
  containers.cardano-node-preprod = {
    nixpkgs = inputs.nixpkgs-2411;
    privateNetwork = true;
    autoStart = true;
    hostAddress = "172.16.0.1";
    localAddress = "172.16.0.2";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
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

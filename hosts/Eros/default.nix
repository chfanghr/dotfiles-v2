{
  inputs,
  config,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko-config.nix
    ./hacks.nix
    ./management.nix
    ./nix.nix
    ./prometheus.nix
    ./router.nix
    ./vpn-gateway.nix
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "Eros";

  time.timeZone = "Asia/Hong_Kong";

  services.iperf3.enable = true;

  age.secrets."oizys-pap-password".file = ../../secrets/oizys-pap-password.age;

  eros.networking = {
    wan = {
      mode = "pppoe";
      pppoe = {
        username = "075488857405";
        passwordFile = config.age.secrets."oizys-pap-password".path;
      };
    };

    debug = false;
  };

  system.stateVersion = "24.11";
}

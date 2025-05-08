{
  lib,
  config,
  ...
}: {
  services.generate-nix-cache-key.enable = lib.mkForce false;

  age.secrets.nix-cache-key = {
    owner = "root";
    group = "root";
    mode = "0400";
    file = ../../secrets/demeter-nix-cache-key.age;
  };

  nix.settings.secret-key-files = config.age.secrets.nix-cache-key.path;
}

{
  lib,
  config,
  ...
}: {
  services.generate-nix-cache-key.enable = lib.mkForce false;

  age.secrets.nix-cache-key = {
    file = ../../secrets/hestia-nix-cache-key.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  nix.settings.secret-key-files = config.age.secrets.nix-cache-key.path;
}

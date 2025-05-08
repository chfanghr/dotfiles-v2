{lib, ...}: {
  services.generate-nix-cache-key.enable = lib.mkForce false;

  age.secrets.nix-cache-key = {
    owner = "root";
    group = "root";
    mode = "0400";
    path = "/etc/nix/private-key";
    file = ../../secrets/persephone-nix-cache-key.age;
  };

  nix.settings = {
    download-buffer-size = 1000000000;
    secret-key-files = "/etc/nix/private-key";
  };
}

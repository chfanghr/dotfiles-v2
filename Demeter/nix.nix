{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./modules/generate-nix-cache-key.nix
  ];

  nix = {
    package = pkgs.nixVersions.nix_2_21;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      trusted-users = [
        "root"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org?priority=2"
        "https://mlabs.cachix.org?priority=3"
        "https://iohk.cachix.org?priority=999"
      ];
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
        "mlabs.cachix.org-1:gStKdEqNKcrlSQw5iMW6wFCj3+b+1ASpBVY2SYuNV2M="
      ];
    };
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.services.generate-nix-cache-key.privateKeyPath;
      openFirewall = true;
      package = pkgs.nix-serve-ng;
    };

    generate-nix-cache-key.enable = true;
  };
}

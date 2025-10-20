{inputs, ...}: {
  imports = [
    ./boot.nix
    ./disko-config.nix
    inputs.disko.nixosModules.default
  ];

  networking = {
    useNetworkd = true;
    hostName = "Telephus";
    interfaces.enp0s1.useDHCP = true;
  };

  virtualisation.rosetta.enable = true;

  users.users.fanghr = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK39RaEP0hXf6IiC2GPgxBAX6H4F6apkfEVY11ZeZNy7 fanghr@bruh"
    ];
    hashedPassword = "$y$j9T$sUiL3HdtLj7MZAsxCkWYV1$4mGt.J0JppEhcRT5PqMeYhxnsFI1M2hpz0l95SluoND";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh.enable = true;

  time.timeZone = "Asia/Singapore";

  system.stateVersion = "25.05";

  nixpkgs.hostPlatform = "aarch64-linux";
}

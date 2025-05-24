{inputs, ...}: {
  imports = [
    ./artemis-telemetry.nix
    ./boot.nix
    ./disko.nix
    ./impermanence.nix
    ./networking.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.impermanence.nixosModules.default
  ];

  dotfiles.nixos.props = {
    hardware = {
      cpu.intel = true;
      vmHost = true;
    };
    nix.roles.consumer = true;
    ociHost = true;
  };

  networking.hostName = "Eros";

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$zOPTGKuw0I7uCBkW1Y3pV1$cm7EDph6molwLwx2iGrD2frPvADEzExs7jwDQaCVOn0";

  nixpkgs.hostPlatform = "x86_64-linux";
}

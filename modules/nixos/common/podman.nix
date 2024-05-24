{
  config,
  lib,
  ...
}:
lib.mkIf (config.dotfiles.hasProp "is-container-host") {
  virtualisation.podman = {
    enable = true;
    # networkSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {dns_enabled = true;};
  };

  boot.binfmt.emulatedSystems = [
    "x86_64-windows"
    "aarch64-linux"
  ];
}

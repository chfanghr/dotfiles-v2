{
  networking.hostName = "Demeter";

  imports = [
    ./containers
    ./users
    ./avahi.nix
    ./boot.nix
    ./clamav.nix
    ./misc.nix
    ./file-systems.nix
    ./grafana.nix
    ./hardware.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./podman.nix
    ./prometheus.nix
    ./rgb.nix
    ./tailscale.nix
    ./traefik.nix
    ./video.nix
    ./vscode.nix
  ];

  system.stateVersion = "23.11";
}

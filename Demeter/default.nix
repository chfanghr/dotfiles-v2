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
    ./pipewire.nix
    ./podman.nix
    ./prometheus.nix
    ./rgb.nix
    ./tailscale.nix
    ./traefik.nix
    ./video.nix
    ./vscode.nix
  ];

  specialisation.debug.configuration = {services.journald.console = "/dev/console";};

  system.stateVersion = "24.05";
}

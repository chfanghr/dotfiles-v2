{
  networking.hostName = "Demeter";

  imports = [
    ./containers
    ./users
    ./avahi.nix
    ./boot.nix
    ./clamav.nix
    ./file-systems.nix
    ./grafana.nix
    ./bluetooth.nix
    ./hardware.nix
    ./misc.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./pipewire.nix
    ./podman.nix
    ./prometheus.nix
    ./rgb.nix
    ./security.nix
    ./tailscale.nix
    ./traefik.nix
    ./vscode.nix
  ];

  specialisation.debug.configuration = {services.journald.console = "/dev/console";};

  system.stateVersion = "24.05";
}

{
  virtualisation.podman = {
    enable = true;
    # networkSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {dns_enabled = true;};
  };
}

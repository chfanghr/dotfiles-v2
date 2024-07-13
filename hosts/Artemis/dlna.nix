{
  services.minidlna = {
    enable = true;
    settings = {
      notify_interval = 60;
      friendly_name = "Artemis";
      media_dir = [
        "P,/mnt/tank/media/NSFW_PICS"
      ];
      inotify = "yes";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [8200];
    allowedUDPPorts = [1900];
  };
}

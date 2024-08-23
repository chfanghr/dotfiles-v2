{
  services.minidlna = {
    enable = true;
    settings = {
      notify_interval = 60;
      inotify = "yes";
    };
    openFirewall = true;
  };
}

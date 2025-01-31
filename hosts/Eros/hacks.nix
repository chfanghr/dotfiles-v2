{
  systemd = {
    timers = {
      periodic-reboot = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "3d";
          Unit = "reboot.target";
        };
      };
    };
  };
}

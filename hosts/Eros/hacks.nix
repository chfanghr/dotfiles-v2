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
      force-start-pppd-main = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnUnitInactiveSec = "60";
          Unit = "pppd-main.service";
        };
      };
    };
  };
}

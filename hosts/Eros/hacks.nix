{pkgs, ...}: {
  systemd = {
    timers = {
      periodic-reboot = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "3d";
          Unit = "reboot.target";
        };
      };
      check-online = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnUnitInactiveSec = "15m";
        };
      };
    };

    services.check-online = {
      wantedBy = ["multi-user.target"];
      path = [
        pkgs.curl
      ];
      environment = {
        CURL_CA_BUNDLE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
      script = ''
        curl --connect-timeout 5 \
          --max-time 10 \
          --retry 5 \
          --retry-delay 10 \
          --retry-max-time 40 \
          --retry-all-errors \
          -v \
          'https://www.google.cn/generate_204'
      '';
      # unitConfig.FailureAction = "reboot";
      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
        User = "nobody";
        Group = "nogroup";
      };
    };
  };
}

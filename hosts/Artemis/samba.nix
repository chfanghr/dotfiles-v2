{
  services.samba.shares = {
    tank = {
      path = "/mnt/tank";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "fanghr";
      writeable = "yes";
    };
    guest = {
      path = "/mnt/tank/Guest";
      browseable = "yes";
      "guest ok" = "yes";
      writeable = "no";
    };
  };
}

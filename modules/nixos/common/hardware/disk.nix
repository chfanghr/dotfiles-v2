{lib, ...}: {
  services.smartd = {
    enable = lib.mkDefault true;
    autodetect = true;
  };
}

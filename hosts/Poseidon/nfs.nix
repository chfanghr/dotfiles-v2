{
  systemd.tmpfiles.settings."10-minecraft-main" = {
    "/srv/minecraft/main/world" = {
      d = {
        mode = "0700";
        user = "minecraft";
      };
    };
  };

  fileSystems."/srv/minecraft/main/world" = {
    device = "10.41.255.234:/minecraft/main";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  boot.supportedFilesystems = ["nfs"];
}

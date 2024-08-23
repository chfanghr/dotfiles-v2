{
  pkgs,
  config,
  ...
}: {
  # age.secrets."artemis-cifs-credential.age".file = ../../secrets/artemis-cifs-credential.age;
  # environment.systemPackages = [pkgs.cifs-utils];
  # fileSystems."/mnt/artemis/qbittorrent" = {
  #   device = "//artemis/qbittorrent";
  #   fsType = "cifs";
  #   options = let
  #     # this line prevents hanging on network split
  #     automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #   in ["${automount_opts},credentials=${config.age.secrets."artemis-cifs-credential.age".path}"];
  # };

  age.secrets."yotsuba.key".file = ../../secrets/yotsuba.key.age;

  environment.etc.crypttab = {
    enable = true;
    text = ''
      yotsuba1 UUID=dbd62b38-df5b-49c5-8220-ce800e5f70ec ${config.age.secrets."yotsuba.key".path} luks
      yotsuba2 UUID=acd9a17f-9d6e-404d-b096-fe31375db513 ${config.age.secrets."yotsuba.key".path} luks
    '';
  };

  environment.systemPackages = [pkgs.cryptsetup];

  systemd.tmpfiles.settings.fanghr."/mnt/yotsuba".d = {
    inherit (config.services.qbittorrent) user group;
    mode = "0500";
  };

  fileSystems."/mnt/yotsuba" = {
    device = "/dev/mapper/yotsuba1";
    fsType = "btrfs";
    options = [
      "defaults"
      "ro"
    ];
  };
}

{
  pkgs,
  lib,
  ...
}: {
  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true;

  services.nfs = {
    settings = {
      gssd = {
        verbosity = 3;
      };
    };
    idmapd.settings = {
      General = {
        Domain = "snow-dace.ts.net";
        Verbosity = 3;
      };
      Translation = {
        Method = lib.mkForce "static,nsswitch";
      };
      Mapping = {
        Nobody-User = "nobody";
        Nobody-Group = "nogroup";
      };
      Static = {
        "fanghr@snow-dace.ts.net" = "fanghr";
        "minecraft@snow-dace.ts.net" = "minecraft";
      };
    };
  };

  environment.systemPackages = [
    pkgs.nfs-utils
  ];

  systemd.tmpfiles.settings."10-nfs-mount-points" = {
    "/data/nfs-test" = {
      d = {
        mode = "0755";
        user = "nobody";
        group = "nogroup";
      };
    };
  };

  fileSystems = {
    "/data/nfs-test" = {
      device = "persephone.snow-dace.ts.net:/nfs-test";
      fsType = "nfs";
      options = ["nfsvers=4.2" "x-systemd.automount" "noauto"];
    };
  };
}

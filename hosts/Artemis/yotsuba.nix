{
  services.btrfs.autoScrub.fileSystems = ["/mnt/yotsuba"];

  environment.etc.crypttab = {
    enable = true;
    text = ''
      yotsuba1 UUID=dbd62b38-df5b-49c5-8220-ce800e5f70ec /etc/secrets/yotsuba/yotsuba.key luks
      yotsuba2 UUID=acd9a17f-9d6e-404d-b096-fe31375db513 /etc/secrets/yotsuba/yotsuba.key luks
    '';
  };

  fileSystems."/mnt/yotsuba" = {
    device = "/dev/mapper/yotsuba1";
    fsType = "btrfs";
    options = [
      "defaults"
      "noatime"
      "compress=zstd"
    ];
  };
}

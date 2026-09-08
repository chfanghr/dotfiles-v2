{config, ...}: let
  inherit (config.apollo.zfs) pools mkDatasetMountpoint;

  pool = pools.slow;
  dataset = "enc/ollama";

  ollama = config.dotfiles.shared.nixpkgs-unstable.pkgs.ollama-cuda;
in {
  home-manager.users.fanghr = {
    dotfiles.hm.opencode.enable = true;
    home.packages = [ollama];
  };

  disko.devices.zpool = {
    ${pool}.datasets.${dataset} = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = mkDatasetMountpoint pool dataset;
    };
  };

  systemd.tmpfiles.settings."10-ollama-mountpoints" = {
    ${config.disko.devices.zpool.${pool}.datasets.${dataset}.mountpoint}.d = {
      inherit (config.services.ollama) user group;
      mode = "0770";
    };
  };

  services.ollama = {
    enable = true;
    user = "ollama";
    group = "ollama";
    package = ollama;
    home = config.disko.devices.zpool.${pool}.datasets.${dataset}.mountpoint;
    loadModels = [
      "llama3.2:3b"
      "qwen3.8:27b"
      "tinyrick/Qwen3.8-27B-Ultra-Uncensored-Heretic-Native-MTP-Preserved-GGUF:Q6_K"
      "ornith-1.5:35b"
    ];
  };
}

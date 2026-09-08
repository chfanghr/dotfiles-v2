{config, ...}: let
  inherit (config.apollo.zfs) pools mkDatasetMountpoint;

  pool = pools.slow;
  dataset = "enc/ollama";
in {
  disko.devices.zpool = {
    ${pool}.datasets.${dataset} = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = mkDatasetMountpoint pool dataset;
    };
  };

  services.ollama = {
    enable = true;
    package = config.dotfiles.shared.nixpkgs-unstable.pkgs.ollama-cuda;
    home = config.disko.devices.zpool.${pool}.datasets.${dataset}.mountpoint;
    loadModels = [
      "llama3.2:3b"
      "qwen3.8:27b"
      "tinyrick/Qwen3.8-27B-Ultra-Uncensored-Heretic-Native-MTP-Preserved-GGUF:Q6_K"
      "ornith-1.5:35b"
    ];
  };
}

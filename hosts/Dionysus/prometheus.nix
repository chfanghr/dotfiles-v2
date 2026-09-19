{config, ...}: let
  hostName = config.networking.hostName;
  port = 9835;

  # The exporter in the pinned nixpkgs (1.4.1) predates per-process metrics
  # support (--collect.compute-apps, added in 1.9.0), so use the one from
  # nixpkgs-unstable instead.
  exporterPackage = config.dotfiles.shared.nixpkgs-unstable.pkgs.prometheus-nvidia-gpu-exporter;
in {
  services.prometheus.scrapeConfigs = [
    {
      job_name = "${hostName}-nvidia";
      static_configs = [
        {
          targets = ["127.0.0.1:${toString port}"];
          labels.instance = hostName;
        }
      ];
    }
  ];

  # Self-contained copy of the upstream services.prometheus.exporters.nvidia-gpu
  # module (including the hardening the exporter framework applies), so that
  # the package and the command line flags stay under our control.
  systemd.services.prometheus-nvidia-gpu-exporter = {
    description = "Prometheus exporter for NVIDIA GPU metrics";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      ExecStart = ''
        ${exporterPackage}/bin/nvidia_gpu_exporter \
          --web.listen-address 127.0.0.1:${toString port} \
          --nvidia-smi-command ${config.hardware.nvidia.package.bin}/bin/nvidia-smi \
          --collect.compute-apps
      '';
      Restart = "always";
      PrivateTmp = true;
      WorkingDirectory = "/tmp";
      DynamicUser = true;
      User = "nvidia-gpu-exporter";
      Group = "nvidia-gpu-exporter";
      CapabilityBoundingSet = [""];
      DeviceAllow = [""];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = false;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (config.dotfiles) hasProp;
in
  mkMerge [
    {
      hardware.enableRedistributableFirmware = mkDefault true;
    }

    (mkIf (hasProp "has-nvidia-gpu") {
      services.xserver.videoDrivers = [
        "nvidia"
      ];
      hardware.nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
        package = config.dotfiles.hardware.nvidia.driver;
      };
      hardware.opengl.extraPackages = with pkgs; [
        vaapiVdpau
      ];
    })
    (
      mkIf (hasProp "has-amd-gpu") {
        hardware.opengl = {
          extraPackages = with pkgs; [
            amdvlk
          ];

          extraPackages32 = with pkgs; [
            driversi686Linux.amdvlk
          ];
        };

        boot.initrd.kernelModules = ["amdgpu"];

        services.xserver.videoDrivers = mkDefault ["modesetting"];
      }
    )
    (
      mkIf (hasProp "has-amd-cpu") {
        boot = {
          kernelModules = ["kvm-amd"];
          kernelPackages = pkgs.linuxPackages_latest;
          kernelParams = ["amdgpu.sg_display=0" "amd_pstate=active"];
        };
        hardware.cpu.amd.updateMicrocode = true;
      }
    )
    (
      mkIf (hasProp "has-intel-cpu") {
        hardware.cpu.intel.updateMicrocode = true;

        boot = {
          kernelModules = [
            "kvm-intel"
          ];
          extraModprobeConfig = "options kvm_intel nested=1";
        };
      }
    )
    (
      mkIf (hasProp "is-graphical") {
        powerManagement.cpuFreqGovernor = "ondemand";
      }
    )
    (
      mkIf (hasProp "uses-yubikey") {
        hardware.gpgSmartcards.enable = true;
        services.pcscd.enable = true;
      }
    )
  ]

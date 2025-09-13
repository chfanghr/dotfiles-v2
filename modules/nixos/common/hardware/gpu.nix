{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge types mkOption mdDoc mkDefault mkForce;

  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };

  gpuProps = config.dotfiles.nixos.props.hardware.gpu;

  graphicalProps = config.dotfiles.shared.props.purposes.graphical;

  inherit (config.dotfiles.shared.props.hardware) steamdeck;
in {
  options.dotfiles.nixos.props.hardware.gpu = {
    nvidia = mkPropOption "has nvidia graphics cards";
    amd = {
      integrated.raphael = mkPropOption "has enabled hacks for integrated amd gpu(Raphael)";
      enable = mkPropOption "has amd graphics cards";
      amdvlk.enable = mkPropOption "use amdvlk driver";
    };
    intel = mkPropOption "has intel graphics cards";
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = (graphicalProps.gaming || graphicalProps.desktop) -> (gpuProps.nvidia || gpuProps.amd.enable || steamdeck);
          message = "For graphical purposes, a graphics card must be available";
        }
      ];
    }
    (
      mkIf ((graphicalProps.gaming || graphicalProps.desktop) && !config.dotfiles.shared.props.hardware.steamdeck) {
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
      }
    )
    (
      mkIf gpuProps.nvidia {
        services.xserver.videoDrivers = [
          "nvidia"
        ];
        hardware.nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          package = mkDefault config.boot.kernelPackages.nvidiaPackages.beta;
          dynamicBoost.enable = true;
        };
        hardware.graphics.extraPackages = with pkgs; [
          vaapiVdpau
        ];
        nixpkgs.config.allowUnfreePredicate = pkg: config.hardware.nvidia.package.name == lib.getName pkg;
      }
    )
    (
      mkIf gpuProps.amd.enable (mkMerge [
        {
          hardware.amdgpu = {
            initrd.enable = true;
            opencl.enable = true;
            overdrive.enable = mkDefault true;
          };
          # services.xserver.videoDrivers = mkDefault ["modesetting"];
        }
        (
          mkIf gpuProps.amd.amdvlk.enable {
            hardware.amdgpu.amdvlk = {
              enable = true;
              support32Bit.enable = true;
            };
          }
        )
        (
          mkIf gpuProps.amd.integrated.raphael {
            boot = {
              kernelPackages = mkForce pkgs.linuxPackages_latest;
              kernelParams = ["amdgpu.sg_display=0"];
            };
          }
        )
      ])
    )
    (
      mkIf gpuProps.intel {
        hardware.graphics.extraPackages = [
          pkgs.vpl-gpu-rt
          pkgs.intel-compute-runtime
        ];
      }
    )
  ];
}

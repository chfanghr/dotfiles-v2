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
    };
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
        nixpkgs.config.allowUnfreePredicate = pkg_name: config.hardware.nvidia.package.name == pkg_name;
      }
    )
    (
      mkIf gpuProps.amd.enable (mkMerge [
        {
          hardware.amdgpu = {
            amdvlk = {
              enable = true;
              support32Bit.enable = true;
            };
            initrd.enable = true;
          };
          # services.xserver.videoDrivers = mkDefault ["modesetting"];
        }
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
  ];
}

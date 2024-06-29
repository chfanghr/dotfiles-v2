{
  lib,
  config,
  pkgs,
  inputs,
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

  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
        hardware.opengl = {
          enable = true;
          package = pkgs-unstable.mesa.drivers;
          package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
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
        };
        hardware.opengl.extraPackages = with pkgs; [
          vaapiVdpau
        ];
        nixpkgs.config.allowUnfree = true;
      }
    )
    (
      mkIf gpuProps.amd.enable (mkMerge [
        {
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

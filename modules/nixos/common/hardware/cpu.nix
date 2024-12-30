{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkMerge types mkOption mdDoc xor;

  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };

  cpuProps = config.dotfiles.nixos.props.hardware.cpu;

  graphicalProps = config.dotfiles.shared.props.purposes.graphical;
in {
  imports = [
    inputs.ucodenix.nixosModules.default
  ];

  options.dotfiles.nixos.props.hardware.cpu = {
    amd = mkPropOption "has a amd cpu";
    intel = mkPropOption "has a intel cpu";

    tweaks = {
      amd = {
        noPstate = mkPropOption "don't use amd_spstate";
      };
    };
  };

  config =
    mkIf
    (!config.dotfiles.shared.props.hardware.steamdeck)
    (mkMerge [
      {
        assertions = [
          {
            assertion = xor cpuProps.amd cpuProps.intel;
            message = "A machine can either have an amd or intel cpu, never both, never none";
          }
        ];
      }
      (
        mkIf cpuProps.amd (mkMerge [
          {
            hardware.cpu.amd.updateMicrocode = true;
          }
          (mkIf (!cpuProps.tweaks.amd.noPstate) {
            boot.kernelParams = ["amd_pstate=active"];
          })
        ])
      )
      (
        mkIf cpuProps.intel {
          hardware.cpu.intel.updateMicrocode = true;
        }
      )
      (
        mkIf (graphicalProps.desktop || graphicalProps.gaming) {
          powerManagement.cpuFreqGovernor = "ondemand";
        }
      )
    ]);
}

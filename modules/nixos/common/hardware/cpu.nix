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
    aarch64 = mkPropOption "has a aarch64 cpu";

    tweaks = {
      amd = {
        noPstate = mkPropOption "don't use amd_spstate";

        trustUCode = mkPropOption "trust amd microcode updates from ucode-nix";
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
            assertion = xor (xor cpuProps.amd cpuProps.intel) cpuProps.aarch64;
            message = "A machine can either have an amd or intel cpu, never both, never none";
          }
        ];
      }
      (
        mkIf cpuProps.amd (mkMerge [
          {
            hardware.cpu.amd.updateMicrocode = true;
            nixpkgs.hostPlatform = "x86_64-linux";
          }
          (mkIf (!cpuProps.tweaks.amd.noPstate) {
            boot.kernelParams = ["amd_pstate=active"];
          })
          (mkIf (cpuProps.tweaks.amd.trustUCode) {
            boot.kernelParams = ["microcode.amd_sha_check=off"];
          })
        ])
      )
      (
        mkIf cpuProps.intel {
          hardware.cpu.intel.updateMicrocode = true;
          nixpkgs.hostPlatform = "x86_64-linux";
        }
      )
      (
        mkIf (graphicalProps.desktop || graphicalProps.gaming) {
          powerManagement.cpuFreqGovernor = "ondemand";
        }
      )
      (mkIf cpuProps.aarch64 {nixpkgs.hostPlatform = "aarch64-linux";})
    ]);
}

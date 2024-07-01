{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mdDoc mkIf;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };

  cpuProps = config.dotfiles.nixos.props.hardware.cpu;

  enabled = config.dotfiles.nixos.props.hardware.emulation;
in {
  options.dotfiles.nixos.props.hardware.emulation = mkPropOption "emulate other cpu archs or OSs";

  config = mkIf enabled {
    assertions = [
      {
        assertion = enabled -> (cpuProps.amd || cpuProps.intel);
        message = "Emulation can only be enabled on x86_64 cups";
      }
    ];

    boot.binfmt.emulatedSystems = [
      "x86_64-windows"
      "aarch64-linux"
    ];
  };
}

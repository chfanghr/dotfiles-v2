{inputs, ...}: {
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
  ];

  perSystem = {config, ...}: {
    pre-commit = {
      check.enable = true;
      settings.hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
      };
    };
    devShells.pre-commit = config.pre-commit.devShell;
  };
}

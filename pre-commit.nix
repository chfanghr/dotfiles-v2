{inputs, ...}: {
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
  ];

  perSystem = {
    config,
    inputs',
    ...
  }: {
    pre-commit = {
      check.enable = true;
      settings.hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
      };
    };
    devShells.default = config.pre-commit.devShell.overrideAttrs (_: prev: {
      buildInputs =
        (
          if prev ? buildInputs
          then prev.buildInputs
          else []
        )
        ++ [
          inputs'.agenix.packages.default
        ];
    });
  };
}

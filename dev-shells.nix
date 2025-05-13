{
  perSystem = {
    self',
    inputs',
    pkgs,
    ...
  }: {
    devShells.default = self'.devShells.pre-commit.overrideAttrs (_: prev: {
      buildInputs =
        (
          if prev ? buildInputs
          then prev.buildInputs
          else []
        )
        ++ [
          inputs'.agenix.packages.default
          inputs'.disko.packages.default
          inputs'.nixos-anywhere.packages.default
          pkgs.nurl
        ];
    });
  };
}

{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.vscode-server.nixosModules.default];

  config = lib.mkIf (config.dotfiles.hasProp "runs-vscode-code-server") {
    services.vscode-server.enable = true;
  };
}

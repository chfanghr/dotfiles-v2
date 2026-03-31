{inputs, ...}: {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    enableManpages = true;
    defaultEditor = true;
    settings = import ./nvf.nix;
  };
}

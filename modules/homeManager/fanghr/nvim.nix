{inputs, ...}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim =
    {
      enable = true;
      defaultEditor = true;
    }
    // inputs.my-nvim.nvimModules.default;
}

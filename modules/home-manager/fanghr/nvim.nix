{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim =
    {
      enable = true;
      defaultEditor = true;
    }
    // inputs.my-nvim.nvimModules.default;
}

{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    enableManpages = true;
    defaultEditor = true;
    settings = {
      imports = [./nvf.nix];
      custom = {inherit (config.dotfiles.shared.props.purposes) lightweight;};
    };
  };
}

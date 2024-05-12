{
  imports = [
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./sway.nix
    ./nvim.nix
    ./packages.nix
    ./pueue.nix
    ./ssh.nix
    ./vscode.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}

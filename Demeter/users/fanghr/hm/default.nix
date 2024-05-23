{
  imports = [
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./hyprland.nix
    ./sway.nix
    ./nvim.nix
    ./packages.nix
    ./pueue.nix
    ./ssh.nix
    ./tmate.nix
    ./vscode.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}

{
  imports = [
    ./alacritty.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./hyprland.nix
    ./nvim.nix
    ./packages.nix
    ./pueue.nix
    ./ssh.nix
    ./tmate.nix
    ./vscode.nix
    ./zsh.nix
    ../../shared
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}

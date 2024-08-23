{
  imports = [
    ./alacritty.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./mangohud.nix
    ./hyprland.nix
    ./nvim.nix
    ./obs.nix
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

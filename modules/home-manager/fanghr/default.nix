{inputs, ...}: {
  imports = [
    ./alacritty.nix
    ./direnv.nix
    ./emacs.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./jj.nix
    ./mangohud.nix
    ./niri.nix
    ./niri-noctalia.nix
    ./nvim.nix
    ./obs.nix
    ./opencode.nix
    ./packages.nix
    ./pueue.nix
    ./ssh.nix
    ./wezterm.nix
    ./vscode.nix
    ./zsh.nix
    ../../shared
    inputs.noctalia.homeModules.default
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}

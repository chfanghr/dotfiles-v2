{pkgs, ...}: {
  home.packages = with pkgs; [
    # misc
    httpie
    usbutils
    bat
    htop
    netcat
    coreutils
    pinentry-curses
    psmisc
    jq
    gnumake
    treefmt
    ripgrep
    wakatime
    tmux
    multimarkdown
    distrobox

    # nix
    nixpkgs-fmt
    alejandra
    nil
    nix-output-monitor
    nix-prefetch-github

    # fonts
    nerdfonts
  ];
}

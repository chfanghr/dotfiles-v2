{
  pkgs,
  lib,
  ...
}: {
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
    btop
    dua
    spotify
    moonlight-qt

    # nix
    nixpkgs-fmt
    alejandra
    nil
    nix-output-monitor
    nix-prefetch-github

    # fonts
    nerdfonts
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
    ];
}

{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkMerge [
  {
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

      # nix
      nixpkgs-fmt
      alejandra
      nil
      nix-output-monitor
      nix-prefetch-github
    ];
  }
  (
    lib.mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
      home.packages = with pkgs; [
        spotify
        moonlight-qt

        # fonts
        nerdfonts
      ];
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "spotify"
        ];
    }
  )
]

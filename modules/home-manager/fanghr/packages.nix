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
      dig

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

        # fonts
        nerdfonts

        signal-desktop
        telegram-desktop
        discord

        vlc

        zed-editor
      ];
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "spotify"
        ];
    }
  )
  (
    lib.mkIf config.dotfiles.shared.props.purposes.graphical.gaming {
      home.packages = with pkgs; [
        moonlight-qt
      ];
    }
  )
]

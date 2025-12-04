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
      wakatime-cli
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

      fastfetch
    ];
  }
  (
    lib.mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
      home.packages = with pkgs; [
        spotify

        signal-desktop
        telegram-desktop
        discord

        vlc

        zed-editor

        thunderbolt
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

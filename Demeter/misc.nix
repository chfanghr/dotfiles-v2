{pkgs, ...}: {
  boot.binfmt.emulatedSystems = [
    "x86_64-windows"
    "aarch64-linux"
  ];

  time.timeZone = "Asia/Hong_Kong";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    curl
    btop
    coreutils
    file
    openrgb
  ];

  programs = {
    zsh = {
      enable = true;
      enableBashCompletion = true;
    };
    git.enable = true;
    neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
    tmux.enable = true;
    mosh.enable = true;
    nix-ld.enable = true;
  };

  services.journald.console = "/dev/console";
}

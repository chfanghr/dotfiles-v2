{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    curl
    btop
    coreutils
    file
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
  };

  i18n.defaultLocale = "en_US.UTF-8";
}

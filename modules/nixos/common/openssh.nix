{config, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin =
        if config.dotfiles.hasProp "allows-root-login"
        then "prohibit-password"
        else "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };
}

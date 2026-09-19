{lib, ...}: let
  inherit (lib) mkDefault;
in {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = mkDefault "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  programs.mosh.enable = true;
}

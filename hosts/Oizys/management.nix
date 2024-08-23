{pkgs, ...}: {
  users = {
    users.fanghr = {
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJnZjDdWnD6KdkEzCW2lZ3Zg7hSYtRYdRPoGJWuR3fJB5ZOYP/zAzGkJ+GngoBc2TAK6hGcZmP3ScLVXb6a12eLrqpNFuq4Ja0zDI+QhItr7WxgeXZcdnrgu8bZ7j70z+PrJq9ZzUVWG3EnnOkRpHG1NC45Bi7Y/sp7gQXrTYxOnq4Hvo4CeUdVno/ImmTgg63IW4qJYUJ+YidiUo5rslwFiVS8XgTJkI1zswvIkurQhWTUoX+nj/Oo7f1w41dwkbjXun44bXQIJO6jrKf8KY9gM1dIwK+pNWYOql/vnItsohlx7CwclwyJl4xcj/21gWgh8AXuJ+kWPPUnm2DrAnbDN2W/8kboa7DpFrg5oiDaLU9Q3n1abIBraujhY3pHEg8DYhLB4zqblHlUB2GmaZ9SkfDZyJ01CTuSUJHY/a3duGQGEBXOgWV32F9G5DcUHVr996/I4EMIuPFAbxMA7p4dO4i26y3mg/E6lIzMEGxy38Fg/0PVUEsI5tk6vIbPrI+AkDWIBjQwFodQaC1elXSFcwVD+Fx8bCQk2coFhO8fG1yr41AH3ZRg8i5MmaTSu49Pqj3wVRJs2NJKkh4Cm0LFJqmb6ReYK0KOqB/hLCXSYhrBmmS4/hwhqPZ3GRkzHWvwVk14yeDoLW7TchCr3L4a87jnXp3mkNnVGGwGgacMQ== cardno:19 342 978"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErEFbKgAG7yvw8MlrwtZ6M4/VrBrPTenxKcHEpjF1XH chfanghr@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK39RaEP0hXf6IiC2GPgxBAX6H4F6apkfEVY11ZeZNy7 fanghr@bruh"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoVXyX0kHBZLz1MDvsLS2Ei/l+7Vm84vMyqgEtL6EhH fanghr@Demeter"
      ];
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = "$y$j9T$7dnMKGQ3hN2O.R1PLZayo0$CsGDfB0E4ypasDxBFTaLDxhFpfk1mLhoVwe8nBm.VkD";
      createHome = true;
      home = "/home/fanghr";
      shell = pkgs.zsh;
    };
    mutableUsers = false;
  };

  services = {
    tailscale.enable = true;

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  programs = {
    zsh.enable = true;
    htop.enable = true;
  };

  environment.defaultPackages = [
    pkgs.fastfetch
    pkgs.dig
    pkgs.ethtool
    pkgs.inetutils
    pkgs.speedtest-cli
  ];
}

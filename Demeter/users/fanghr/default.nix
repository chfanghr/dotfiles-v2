{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  users.users.fanghr = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "cardano-node"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJnZjDdWnD6KdkEzCW2lZ3Zg7hSYtRYdRPoGJWuR3fJB5ZOYP/zAzGkJ+GngoBc2TAK6hGcZmP3ScLVXb6a12eLrqpNFuq4Ja0zDI+QhItr7WxgeXZcdnrgu8bZ7j70z+PrJq9ZzUVWG3EnnOkRpHG1NC45Bi7Y/sp7gQXrTYxOnq4Hvo4CeUdVno/ImmTgg63IW4qJYUJ+YidiUo5rslwFiVS8XgTJkI1zswvIkurQhWTUoX+nj/Oo7f1w41dwkbjXun44bXQIJO6jrKf8KY9gM1dIwK+pNWYOql/vnItsohlx7CwclwyJl4xcj/21gWgh8AXuJ+kWPPUnm2DrAnbDN2W/8kboa7DpFrg5oiDaLU9Q3n1abIBraujhY3pHEg8DYhLB4zqblHlUB2GmaZ9SkfDZyJ01CTuSUJHY/a3duGQGEBXOgWV32F9G5DcUHVr996/I4EMIuPFAbxMA7p4dO4i26y3mg/E6lIzMEGxy38Fg/0PVUEsI5tk6vIbPrI+AkDWIBjQwFodQaC1elXSFcwVD+Fx8bCQk2coFhO8fG1yr41AH3ZRg8i5MmaTSu49Pqj3wVRJs2NJKkh4Cm0LFJqmb6ReYK0KOqB/hLCXSYhrBmmS4/hwhqPZ3GRkzHWvwVk14yeDoLW7TchCr3L4a87jnXp3mkNnVGGwGgacMQ== cardno:19 342 978"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErEFbKgAG7yvw8MlrwtZ6M4/VrBrPTenxKcHEpjF1XH chfanghr@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK39RaEP0hXf6IiC2GPgxBAX6H4F6apkfEVY11ZeZNy7 fanghr@bruh"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$QNGF492EVUDRotin.hBJA.$S0UY7FJKfDiAxmAg6hciTiiyVvEoUgSlhiHFWHvkz.7";
    home = "/home/fanghr";
  };

  programs.zsh.enable = mkDefault true;

  home-manager.users.fanghr = import ./hm;
}

{
  imports = [
    ./fanghr.nix
    ./robertchen.nix
    ./root.nix
    ./thungghuan.nix
  ];

  users.mutableUsers = false;

  home-manager.backupFileExtension = "backup";
}

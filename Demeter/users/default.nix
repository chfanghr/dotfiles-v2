{inputs, ...}: {
  imports = [
    ./thungghuan
    ./fanghr
    inputs.home-manager.nixosModules.home-manager
  ];
}

{inputs, ...}: {
  imports = [
    ./thungghuan
    ./fanghr
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.extraSpecialArgs = { inherit inputs; };
}

{inputs, ...}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-cpu-amd-raphael-igpu
    common-cpu-amd-pstate
    common-gpu-amd
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware = {
    enableRedistributableFirmware = true;
    amdgpu.amdvlk = true;
    opengl.enable = true;
  };
}

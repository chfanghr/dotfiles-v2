{...}: {
  perSystem = {pkgs, ...}: {
    packages.minecraft-prometheus-exporter = pkgs.callPackage ./minecraft-prometheus-exporter.nix {};
  };
}

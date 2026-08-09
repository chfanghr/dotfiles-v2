{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "minecraft-prometheus-exporter";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "dirien";
    repo = "minecraft-prometheus-exporter";
    tag = "v${version}";
    hash = "sha256-wk+GCVsQGS15HCUfKcTBM9E26vXSPk10QcAGwQ6uFBk=";
  };

  vendorHash = "sha256-rB9sLcHAq/teFAdLpipsQQ+FRYmT+RdjO6EgLjaZudU=";

  meta = {
    description = "Prometheus exporter for Minecraft servers";
    homepage = "https://github.com/dirien/minecraft-prometheus-exporter";
    license = lib.licenses.asl20;
    mainProgram = "minecraft-exporter";
  };
}

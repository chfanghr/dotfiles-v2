{pkgs, ...}: {
  services.foldingathome.enable = true;

  systemd.services.foldingathome.environment.OCL_ICD_VENDORS = "${pkgs.pocl}/etc/OpenCL/vendors/";
}

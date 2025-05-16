{
  pkgs,
  lib,
  config,
  ...
}:
let
  kernelPackages = config.boot.kernelPackages;
  new_lg4ff_vff_module = kernelPackages.callPackage ./new-lg4ff {};
in
{
  options.hardware.new-lg4ff_vff.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enables the experimental new-lg4ff driver (version 0.4.1 depuis Git)
      avec le support du retour de force (VFF) pour les volants Logitech.
      Ceci remplace les modules hid-logitech du noyau.
    '';
  };

  config = lib.mkIf config.hardware.new-lg4ff_vff.enable {
    boot = {
      extraModulePackages = [ new_lg4ff_vff_module ];
      kernelModules = [ "hid-logitech-new" ];
    };
  };
}

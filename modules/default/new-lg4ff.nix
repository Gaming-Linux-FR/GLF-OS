{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.hardware.new-lg4ff;
  kernelPackages = config.boot.kernelPackages;
  new-lg4ff_vff = config.boot.kernelPackages.callPackage ./new-lg4ff {};
    all-users = builtins.attrNames config.users.users;
    normal-users = builtins.filter (user: config.users.users.${user}.isNormalUser == true) all-users;
in
{
  options.hardware.new-lg4ff = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enables improved Linux module drivers for Logitech driving wheels.
        This will replace the existing in-kernel hid-logitech modules.
        Works most notably on the Logitech G25, G27, G29 and Driving Force (GT).
      '';
    };
  };

  config = lib.mkIf config.hardware.new-lg4ff_vff.enable {
    boot = {
      extraModulePackages = [ new-lg4ff_vff ];
      kernelModules = [ "hid-logitech-new" ];
    };
  };
}

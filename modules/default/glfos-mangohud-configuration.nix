{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

let
  glfos-mangohud-configuration = pkgs.callPackage ../../pkgs/glfos-mangohud-configuration {};
in
{

 options.glf.gaming.enable = lib.mkOption { # Use 'lib.mkOption' here
    description = "Enable GLF Gaming configurations";
    type = lib.types.bool; 
    default = if (config.glf.environment.edition != "mini") then
      true
    else
      false;
  };

  config = mkIf config.glf.gaming.enable {
    environment.systemPackages = with pkgs; [ glfos-mangohud-configuration zenity ];
  };

}

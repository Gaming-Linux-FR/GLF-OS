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

  options.glf.packages.glfos-mangohud-configuration.enable = mkOption {
    description = "Enable glfos-mangohud-configuration program";
    type = types.bool;
    default = if (config.glf.environment.enable) then
      true
    else
      false;
  };

  config = mkIf config.glf.packages.glfos-mangohud-configuration.enable {
    environment.systemPackages = with pkgs; [ glfos-mangohud-configuration zenity ];
  };

}

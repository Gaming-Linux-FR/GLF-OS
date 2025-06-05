{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

let
  glfos-environment-selection = pkgs.callPackage ../../pkgs/glfos-environment-selection {};
in
{

  options.glf.packages.glfos-environment-selection.enable = mkOption {
    description = "Enable glfos-environment-selection program";
    type = types.bool;
    default = if (config.glf.environment.enable) then
      true
    else
      false;
  };

  config = mkIf config.glf.packages.glfos-environment-selection.enable {
    environment.systemPackages = with pkgs; [ glfos-environment-selection zenity ];
  };

}

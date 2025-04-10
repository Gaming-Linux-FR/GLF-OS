{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

let
  glf-os-environment-selection = pkgs.callPackage ../../pkgs/glf-os-environment-selection {};
in
{

  options.glf.packages.glf-os-environment-selection.enable = mkOption {
    description = "Enable glf-os-environment-selection program";
    type = types.bool;
    default = if (config.glf.environment.enable) then
      true
    else
      false;
  };

  config = mkIf config.glf.packages.glf-os-environment-selection.enable {
    environment.systemPackages = with pkgs; [ glf-os-environment-selection zenity ];
  };

}

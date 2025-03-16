{
  lib,
  config,
  pkgs,
  ...
}:

let
  ### Place custom pkgs here
  GLFfetch = pkgs.callPackage ../../pkgs/GLFfetch { glfIcon = "GLFos"; };
in

{

  options.glf.packages.GLFfetch.enable = lib.mkOption {
    description = "Enable GLFfetch program";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.packages.GLFfetch.enable {
    environment.systemPackages = with pkgs; [
      GLFfetch
    ];

    ### NerdFonts
    fonts.packages = with pkgs; [
      (pkgs.nerd-fonts.droid-sans-mono.overrideAttrs (oldAttrs: { fonts = [ "UbuntuMono" ]; }))
    ];


  };

}

{
  lib,
  config,
  pkgs,
  ...
}:

let
  ### Place custom pkgs here
  GLFfetch = pkgs.callPackage ../../pkgs/GLFfetch {};
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
      (nerdfonts.override { fonts = [ "UbuntuMono" ]; })
    ];
 
    ### Replace actual syntax on 25.05 by:
    #fonts.packages = with pkgs; [ nerd-fonts.ubuntu-mono ];

  };

}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.glf.environment;
in
{
  # declare option
  options.glf.environment = {
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable desktop environment";
    };
    type = lib.mkOption {
      description = "Desktop environment selection";
      type = with types; enum [ "gnome" "plasma" "studio" "studio-pro" ];
      default = "gnome";
    };
  };

  # Import desktop environment configurations
  imports = [
    ./environments/gnome.nix
    ./environments/plasma.nix
    ./environments/studio.nix
  ];

  # Wallpapers
  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    environment = {
      etc = {
         "wallpapers/glf/white.jpg".source = ../../assets/wallpaper/white.jpg;
         "wallpapers/glf/dark.jpg".source = ../../assets/wallpaper/dark.jpg;
      };
    };
  };

}

{ config, lib, pkgs, ... }:
with lib;

{
  # declare option
  options.glf.environment = {
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable desktop environment";
    };
    type = mkOption {
      description = "Desktop environment selection";
      type = with types; enum [ "gnome" "plasma" ];
      default = "gnome";
    };
    edition = mkOption {
      description = "Edition selection";
      type = with types; enum [ "mini" "standard" "studio" "studio-pro" ];
      default = "standard";
    };
  };

  # Import desktop environment configurations
  imports = [
    ./environments/gnome.nix
    ./environments/plasma.nix
    ./environments/studio.nix
  ];

  # Wallpapers
  config = mkIf config.glf.environment.enable {
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    environment = {
      etc = {
         "wallpapers/glf/white.jpg".source = ../../assets/wallpaper/white.jpg;
         "wallpapers/glf/dark.jpg".source = ../../assets/wallpaper/dark.jpg;
      };
      run/current-system/sw/share/backgrounds/gnome = {
         "leather-glf.png".source = ../../assets/wallpaper/leather-glf.png;
      };
    };
  };

}

{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  
  options.glf.system.enable = lib.mkOption {
    description = "Enable GLF systems configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.system.enable {

    time.hardwareClockInLocalTime = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs-unstable; [
        intel-gpu-tools
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        libva
        vulkan-loader
        vulkan-validation-layers
      ];
      extraPackages32 = with pkgs-unstable; [
        intel-gpu-tools
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        libva
       
      ];
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
      priority = 5;
    };

    nix = {
      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
      settings = {
        auto-optimise-store = true;
      };
    };
    
    programs.nix-ld.enable = true;

  };

}

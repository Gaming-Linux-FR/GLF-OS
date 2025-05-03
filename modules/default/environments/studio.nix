{
  lib,
  config,
  pkgs,
  ...
}:

{
  environment.variables = lib.mkIf (config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
    RUSTICL_ENABLE = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";
  };

  hardware.amdgpu = lib.mkIf (config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
    opencl.enable = true; 
  };
  
    environment.systemPackages =
      if config.glf.environment.edition == "studio-pro" then
        with pkgs; [
          blender-hip
          obs-studio
          obs-studio-plugins.obs-vkcapture
          kdePackages.kdenlive
          davinci-resolve-studio
          gimp
          audacity
          freetube
        ]
      else
        with pkgs; [
          blender
          obs-studio
          obs-studio-plugins.obs-vkcapture
          kdePackages.kdenlive
          davinci-resolve
          gimp
          audacity
          freetube
        ];
  };

}

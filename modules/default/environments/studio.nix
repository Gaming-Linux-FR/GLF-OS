{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
    environment.variables = {
          ROC_ENABLE_PRE_VEGA = "1";
          RUSTICL_ENABLE = "radeonsi";
          };
    hardware.amdgpu.opencl.enable = true;
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

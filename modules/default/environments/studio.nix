{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.type == "studio" || config.glf.environment.type == "studio-pro") {
    
    environment.variables = if (builtins.elem "amdgpu" config.services.xserver.videoDrivers) then
      {
        RUSTICL_ENABLE="radeonsi";
        ROC_ENABLE_PRE_VEGA = "1";
      }
    else
      {
      };

    environment.systemPackages =
      if config.glf.environment.type == "studio-pro" then
        with pkgs; [
          blender
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

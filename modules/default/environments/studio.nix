{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  config = lib.mkIf(config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
    systemd.tmpfiles.rules =
      let
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
           paths = with pkgs.rocmPackages; [
            rocblas
            hipblas
            clr
          ];
         };
      in [
        "L+    /opt/rocm/hip  -    -    -      -    ${rocmEnv}"
       ];

    hardware.graphics = {
     enable = true;
      extraPackages = with pkgs-unstable; [
        mesa.opencl
      ];
     };

    environment.variables = {
      ROC_ENABLE_PRE_VEGA = "1";
      RUSTICL_ENABLE = "radeonsi";
    };

    environment.systemPackages =
      if config.glf.environment.edition == "studio-pro" then
        with pkgs; [
          blender-hip
          obs-studio
          obs-studio-plugins.obs-vkcapture
          kdePackages.kdenlive
          davinci-resolve-studio
          gimp3-with-plugins
          audacity
          freetube
        ]
      else
        with pkgs; [
          blender-hip
          obs-studio
          obs-studio-plugins.obs-vkcapture
          kdePackages.kdenlive
          davinci-resolve
          gimp3-with-plugins
          audacity
          freetube
        ];

    programs.obs-studio = {
      enable=true;
      package = pkgs-unstable.obs-studio.override {cudaSupport = true;};
    };
  };
}

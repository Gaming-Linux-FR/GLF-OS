{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
    config = lib.mkIf(config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
boot.extraModulePackages = [
    (pkgs.linuxKernel.packages.linux_6_14.v4l2loopback.overrideAttrs
      ({
        version = "0.13.2-manual";
        src = (pkgs.fetchFromGitHub {
          owner = "umlaeute";
          repo = "v4l2loopback";
          rev = "v0.13.2";
          hash = "sha256-rcwgOXnhRPTmNKUppupfe/2qNUBDUqVb3TeDbrP5pnU=";
        });
      })
    )
  ];

systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        	flatpak install -y com.obsproject.Studio org.inkscape.Inkscape org.blender.Blender org.kde.kdenlive org.gimp.GIMP org.audacityteam.Audacity fr.handbrake.ghb io.freetubeapp.FreeTube
      '';
    };
systemd.tmpfiles.rules = 
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs-unstable.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm/hip  -    -    -     -    ${rocmEnv}"
  ];  

        hardware.graphics = {
            enable = true; 
            extraPackages = with pkgs-unstable; [
            mesa.opencl # Assure que l'implémentation OpenCL de Mesa (Rusticl) est installée
            ];
          };

        environment.variables = {
          ROC_ENABLE_PRE_VEGA = "1";
          RUSTICL_ENABLE = "radeonsi"; 
        };
    
    environment.systemPackages =
      if config.glf.environment.edition == "studio-pro" then
        with pkgs-unstable; [
          davinci-resolve-studio
          ]
      else
        with pkgs-unstable; [
          davinci-resolve
          ];
  };
}

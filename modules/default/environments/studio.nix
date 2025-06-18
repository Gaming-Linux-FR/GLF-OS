{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
    config = lib.mkIf(config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && flatpak install -y flathub org.dupot.easyflatpak
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

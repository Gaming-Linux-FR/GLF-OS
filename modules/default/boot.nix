# Contenu pour modules/default/boot.nix (Version nettoyée)
{
  lib,
  config,
  pkgs,
  ...
}:

let
  # Assurez-vous que ce chemin est correct par rapport à l'emplacement de boot.nix
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};
in
{
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.boot.enable {

    boot.loader.grub.splashImage = ../../assets/wallpaper/dark.jpg;

    boot = {
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false; # Force disable ZFS
      kernelPackages = lib.mkDefault pkgs.linuxPackages_zen; # Default kernel
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" ] else [ ];
      plymouth = {
        enable = true;
        theme = "glfos";
        # La variable plymouth-glfos vient du 'let' ci-dessus
        themePackages = [ plymouth-glfos ];
      };
    }; # Fin boot = { ... }

  }; # Fin config = lib.mkIf ...

} # Fin du module

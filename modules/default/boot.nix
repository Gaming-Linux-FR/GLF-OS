{
  lib,
  config,
  pkgs,
  ...
}:

{
  
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.boot.enable {

    boot.loader.grub.splashImage = ../../assets/boot/glf-bootloader.png;

    boot = {
      tmp.cleanOnBoot = true;
      #supportedFilesystems.zfs = lib.mkDefault false;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" ] else [ ];
      plymouth = {
      enable = true;
      theme = "blockchain";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "blockchain" ];
        })
      ];
    };
   };

  };

}

{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};
  
  # Import d'un commit nixpkgs contenant kernel 6.14.8
  nixpkgs-kernel = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/39f51ddad7a5.tar.gz";
    sha256 = "1g2j8043v7vm6ngxjlhsk0qwgzb1khjlwqigpdy9jdnr1lry4mgh"; # Sera calculé automatiquement
  };
  
  pkgs-kernel = import nixpkgs-kernel {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };
in
{
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkIf config.glf.boot.enable {
    #GLF wallpaper as grub splashscreen
    boot.loader.grub.splashImage = ../../assets/wallpaper/dark.jpg;
    boot.loader.grub.default = "saved";
    boot = {
      # Utilisation du kernel 6.14.8 depuis le commit épinglé
      kernelPackages = pkgs-kernel.linuxPackages_6_14;
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false; # Force disable ZFS
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" "nosplit_lock_mitigate" ] else [ "nosplit_lock_mitigate" ];
      plymouth = {
        enable = true;
        theme = "glfos";
        themePackages = [ plymouth-glfos ];
      };
      kernel.sysctl = {
        vm_swappiness = 100;
        vm_vfs_cache_pressure = 50;
        vm_dirty_bytes = 268435456;
        "vm.page-cluster" = 0;
        vm_dirty_background_bytes = 67108864;
        vm_dirty_writeback_centisecs = 1500;
        kernel_nmi_watchdog = 0;
        kernel_unprivileged_userns_clone = 1;
        kernel_printk = "3 3 3 3";
        kernel_kptr_restrict = 2;
        kernel_kexec_load_disabled = 1;
      };
    }; 
    
    # Utiliser Mesa unstable directement depuis pkgs-unstable
    hardware.graphics = {
      enable = true;
      package = pkgs-unstable.mesa;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };
  }; 
}

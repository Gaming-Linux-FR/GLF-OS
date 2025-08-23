{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};
in
{
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.boot.enable {
    nixpkgs.overlays = [
      (self: super: {
        linuxPackages = super.linuxPackages // {
          kernel = super.linuxPackages.kernel.override {
            structuredExtraConfig = with lib.kernel; {
              HZ_1000 = yes;
              HZ = 1000;
              PREEMPT_FULL = yes;
              IOSCHED_BFQ = yes;
              DEFAULT_BFQ = yes;
              DEFAULT_IOSCHED = "bfq";
              V4L2_LOOPBACK = module;
              HID = yes;
            };
          };
        };
      })
    ];

    environment.systemPackages = with pkgs; [
      grub2_efi
      efibootmgr
    ];

    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"
    '';

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
      configurationName = "GLF-OS";
      splashImage = ../../assets/wallpaper/dark.jpg;
      default = "saved";
      efiInstallAsRemovable = true;
      efiSupport = true;
      enable = true;
      device = "nodev";
      extraInstallCommands = ''
      # Installer GRUB explicitement avec ton ID EFI
      ${pkgs.grub2_efi}/bin/grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot/efi \
        --bootloader-id=glf-os \
        --force \
        --recheck

      # Détection automatique du disque et de la partition de l'ESP
        esp_dev=$(findmnt -no SOURCE /boot/efi)
        disk=/dev/$(lsblk -no pkname $esp_dev)
        part=$(lsblk -no partn $esp_dev)

      # Création automatique de l'entrée NVRAM
      efibootmgr --create \
        --disk /dev/$disk \
        --part $part \
        --loader /EFI/glf-os/grubx64.efi \
        --label "GLF-OS" || true
      '';
  };
};

    boot = {
      kernelPackages = pkgs.linuxPackages;
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false;
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" "nosplit_lock_mitigate" "clearcpuid=514" ] else [ "nosplit_lock_mitigate" ];
      plymouth = {
        enable = true;
        theme = "glfos";
        themePackages = [ plymouth-glfos ];
      };
     kernel.sysctl = {
  "kernel.split_lock_mitigate" = 0;
  "vm.swappiness" = 10;
  "vm.vfs_cache_pressure" = 50;
  "vm.dirty_bytes" = 268435456;
  "vm.max_map_count" = 16777216;
  "vm.dirty_background_bytes" = 67108864;
  "vm.dirty_writeback_centisecs" = 1500;
  "kernel.nmi_watchdog" = 0;
  "kernel.unprivileged_userns_clone" = 1;
  "kernel.printk" = "3 3 3 3";
  "kernel.kptr_restrict" = 2;
  "kernel.kexec_load_disabled" = 1;
};
    };

    hardware.graphics = {
      enable = true;
      package = pkgs.mesa;
      package32 = pkgs.pkgsi686Linux.mesa;
    };
  };
}

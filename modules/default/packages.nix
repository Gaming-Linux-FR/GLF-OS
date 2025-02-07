{
  lib,
  config,
  pkgs,
  ...
}:

{

  options.glf.packages.enable = lib.mkOption {
    description = "Enable GLF Gnome configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.packages.enable {

    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && flatpak install -y flathub org.dupot.easyflatpak
      '';
    };

    # Enable AppImage
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    environment.systemPackages = with pkgs; [
      # APP
      discord
      celluloid
      chromium
      pciutils
      usbutils
      git
      btop
      htop
      transmission_4-gtk

      # Compression
      arj
      brotli
      bzip2
      cpio
      gnutar
      gzip
      lha
      libarchive
      lrzip
      lz4
      lzop
      p7zip
      pbzip2
      pigz
      pixz
      unrar
      unzip
      xz
      zip
      zstd

      # GLF fetch
      (import ./../../packages/GLFfetch { inherit pkgs; })

      # Bureautique
      libreoffice-fresh
      hunspell
      hunspellDicts.fr-moderne
    ];

  };

}

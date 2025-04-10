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

    # Enable AppImage
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    environment.systemPackages = with pkgs; [
      # APP
      discord
      celluloid
      pciutils
      usbutils
      git
      btop
      htop
      transmission_4-gtk
      vivaldi
      libva-utils

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

      # Fetch en attendant GLF-FETCH
      fastfetch

      # Bureautique
      libreoffice-fresh

      # Language
      poppler_data
      hunspell
      hunspellDicts.fr-any
      hyphen
      texlivePackages.hyphen-french
    ];

  };

}

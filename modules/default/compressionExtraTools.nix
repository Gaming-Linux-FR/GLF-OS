{
  lib,
  config,
  pkgs,
  ...
}:

{

  options.glf.compressionExtraTools.enable = lib.mkOption {
    description = "Add other compression tools";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.compressionExtraTools.enable {

    environment.systemPackages = with pkgs; [
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
    ];

  };

}

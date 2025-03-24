{
  lib,
  config,
  pkgs,
  ...
}:

let
  ### Place custom pkgs here
  nix-disk-manager = pkgs.callPackage ../../pkgs/nix-disk-manager {};
in

{

  options.glf.packages.nix-disk-manager.enable = lib.mkOption {
    description = "Enable GLF disk manager";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.packages.nix-disk-manager.enable {
    environment.systemPackages = with pkgs; [
      nix-disk-manager
    ];
  };

}


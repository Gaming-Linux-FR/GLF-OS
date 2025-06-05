{
  lib,
  config,
  pkgs,
  ...
}:

let
  glfos-branding = pkgs.callPackage ../../pkgs/glfos-branding {};
in

{
  environment.systemPackages = with pkgs; [
      glfos-branding
  ];
}

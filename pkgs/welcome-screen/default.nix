# default.nix

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.11-pre.tar.gz";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
# Export glfos_welcome_screen as an attribute at the top level
{
  glfos_welcome_screen = pkgs.callPackage ./glfos_welcome_screen.nix { };
}
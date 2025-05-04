{ config, pkgs, lib, pkgs-unstable, ... }:

let
  system = "x86_64-linux";
  edition = config.glf.environment.edition or "full"; # Ajout de la valeur par défaut
in
if edition == "mini" then
{
  # Si l'édition est "mini", on passe gaming.nix
}
else
{
  options.glf.mangohud.configuration = lib.mkOption {
    type = with lib.types; enum [ "disabled" "light" "full" ];
    default = "light";
    description = "MangoHud configuration";
  };

  config = {

  };
services.udev.extraRules = ''
    # USB
    ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    # Bluetooth
    ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  hardware.new-lg4ff.enable = true;
  hardware.steam-hardware.enable = true;
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
}

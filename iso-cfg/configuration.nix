{ pkgs, lib, ... }:

{

  glf.autoUpgrade = lib.mkForce false;
  glf.nvidia_config.enable = true;
  system.nixos.tags = lib.mkDefault [ "Alpha.v2" ];
  specialisation = {
    nvidia_proprietary_driver = {
      configuration = {
        system.nixos.tags = lib.mkForce [ "nvidia_proprietary_driver-Alpha.v2" ];
        glf.nvidia_config.type = "proprietary";
      };
    };
  };

  i18n.defaultLocale = "fr_FR.UTF-8";

  console.keyMap = "fr";
  services.xserver = {
    xkb.layout = "fr";
    xkb.variant = "";
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "render"
    ];
  };

  networking.hostName = "GLF-OS";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}

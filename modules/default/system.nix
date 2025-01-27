{ lib, config, pkgs, ... }:

{

  options.glf.system.enable = lib.mkOption {
    description = "Enable GLF systems configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.system.enable {

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    zramSwap = {
      enable = false;
      algorithm = "zstd";
      memoryPercent = 25;
      priority = 5;
    };

    nix = {
      optimise = {
	automatic = true;
	dates = [ "weekly" ];
      };
      settings = {
	auto-optimise-store = true;
      };
    };
    
  };

}

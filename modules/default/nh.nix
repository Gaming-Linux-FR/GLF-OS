{ lib, config, ... }:

{

  options.glf.nh.enable = lib.mkOption {
    description = "Enable GLF nh configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.nh.enable {
    environment.variables = {
          NH_FLAKE = "/etc/nixos/flake.nix";
  };

    environment.shellAliases = {
      rebuild = "nh os switch /etc/nixos";
    };

    programs.nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 3";
      };
    };

  };

}

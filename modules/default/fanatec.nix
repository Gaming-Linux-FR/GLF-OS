{ config, pkgs, lib, ... }:

let
    fanatecff = config.boot.kernelPackages.callPackage ./hid-fanatecff {};
    all-users = builtins.attrNames config.users.users;
    normal-users = builtins.filter (user: config.users.users.${user}.isNormalUser == true) all-users;
in
{
    options.hardware.fanatec = {
        enable = lib.mkOption {
            type = with lib.types; bool;
            default = false;
            description = "Enable Fanatec Wheel support";
        };
    };

    config = lib.mkIf config.hardware.fanatec.enable {
        boot.extraModulePackages = [ fanatecff ];
        services.udev.packages = [ fanatecff ];
        boot.kernelModules = [ "hid-fanatec" ];

        environment.systemPackages = with pkgs; [
            linuxConsoleTools                       # needed by udev rules
        ];

        # add all user to games group (to grant r/w on sysfs)
        users.groups.games = {
            members = normal-users;
        };
    };
}

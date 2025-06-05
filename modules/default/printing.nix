{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.glf.printing.enable = lib.mkOption {
    description = "Enable GLF printing configurations.";
    type = lib.types.bool;
    default = if (config.glf.environment.edition != "mini") then
      true
    else
      false;
  };

  config = lib.mkIf config.glf.printing.enable (
    let
      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    in
    {
      services = {

        # Configure printer
        printing = {
          enable = true;
          startWhenNeeded = true;
          drivers = with pkgs; [
            brgenml1cupswrapper
            brgenml1lpr
            brlaser
            cnijfilter2
            epkowa
            gutenprint
            gutenprintBin
            hplip
            
            samsung-unified-linux-driver
            splix
          ];
        };

        # Enable autodiscovery
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        udev.packages = with pkgs; [
          sane-airscan
          utsushi
        ];
      };

      # systemd.services.cups-browsed.enable = false;
      hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
          sane-airscan
          epkowa
          utsushi
        ];
      };

      # To install printers manually
      programs.system-config-printer.enable = true;

      # add all users to group scanner and lp
      users.groups.scanner.members = normalUsers;
      users.groups.lp.members = normalUsers;
    }
  );
}

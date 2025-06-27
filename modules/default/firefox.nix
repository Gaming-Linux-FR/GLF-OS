{ lib, config, ... }:

{

  options.glf.firefox.enable = lib.mkOption {
    description = "Enable GLF firefox configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.firefox.enable {

    programs.firefox = {
      enable = true;
      wrapperConfig.pipewireSupport = true;
      languagePacks = if (config.i18n.defaultLocale == "fr_FR.UTF-8") then [
        "fr"
        "en-US"
      ] else [ ];
      preferences = if (config.i18n.defaultLocale == "fr_FR.UTF-8") then {
        "intl.accept_languages" = "fr-fr,en-us,en";
        "intl.locale.requested" = "fr,en-US";
      } else { };
    };

  };

}

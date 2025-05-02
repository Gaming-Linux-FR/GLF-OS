{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "glfos-mangohud-configuration";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      runtimeInputs = with pkgs; [ coreutils gnused zenity ];
      text = ''
set +o nounset
set -e

error_display_fr="Erreur: La variable d'environnement DISPLAY n'a pas été trouvée, assurez-vous de lancer cette application depuis un environnement de bureau."
error_internet_fr="Erreur: Aucune connection internet n'est disponible."
error_arguments1_fr="Erreur: Le paramètre n'est pas valide (disabled, horizontal, vertical)."
mangohud_title_fr="GLF-OS - Interface de configuration de MangoHud."
mangohud_text_fr="Bienvenue dans l'interface de configuration de MangoHud.\n\nQuelle configuration souhaitez-vous activer ?\n"
mangohud_column_fr="Configuration"
mangohud_ok_label_fr="Appliquer"
exit_label_fr="Quitter"
error_pkexec_fr="Erreur: La commande pkexec n'a pas fonctionné."
error_text_fr="Erreur: GLF-OS n'a pas pu être mis à jour."
reboot_text_fr="Le système a été mis à jour. Les changements prendront effet au prochain démarrage."

error_display_en="Error: DISPLAY env variable was not found, please make sure you run this program from a desktop environment."
error_internet_en="Error: Internet connection is not available."
error_arguments1_en="Error: Invalid parameter (disabled, horizontal, vertical)."
mangohud_title_en="GLF-OS - MangoHud configuration interface"
mangohud_text_en="Welcome to the MangoHud configuration interface.\n\nWhich configuration would you like to activate ?\n"
mangohud_column_en="Configuration"
mangohud_ok_label_en="Apply"
exit_label_en="Exit"
error_pkexec_en="Error: pkexec command failed."
error_text_en="Error: GLF-OS update failed."
reboot_text_en="The system has been updated. Changes will be applied on the next boot."

locale="$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)"

if [ -z "''${DISPLAY}" ]; then
		if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		echo "''${error_display_fr}"
		exit 1
	else
		echo "''${error_display_en}"
		exit 1
	fi
fi

if ! ${pkgs.curl}/bin/curl -L https://github.com/Gaming-Linux-FR/GLF-OS > /dev/null 2>&1; then
	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_fr}" --error --ok-label="''${exit_label_fr}" --text "''${error_internet_fr}"
		exit 1
	else
		${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_en}" --error --ok-label="''${exit_label_en}" --text "''${error_internet_en}"
		exit 1
	fi
fi

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 1 ]; then
	if { [ "''${1}" != "disabled" ] && [ "''${1}" != "horizontal" ] && [ "''${1}" != "vertical" ]; }; then
		if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
			read -rp "''${error_arguments1_fr}"
			exit 1
		else
			read -rp "''${error_arguments1_en}"
			exit 1
		fi
	else
		interface=0
	fi
fi

if [ "''${interface}" -eq 1 ]; then

	mangohud_options_fr=( "Désactivé" "Horizontal" "Vertical" )
	mangohud_options_en=( "Disabled" "Horizontal" "Vertical" )

	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		selected_mangohud=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="''${mangohud_title_fr}" --list --text "''${mangohud_text_fr}" --column "''${mangohud_column_fr}" "''${mangohud_options_fr[@]}" --ok-label="''${mangohud_ok_label_fr}" --cancel-label="''${exit_label_fr}" 2>/dev/null)
	else
		selected_mangohud=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="''${mangohud_title_en}" --list --text "''${mangohud_text_en}" --column "''${mangohud_column_en}" "''${mangohud_options_en[@]}" --ok-label="''${mangohud_ok_label_en}" --cancel-label="''${exit_label_en}" 2>/dev/null)
	fi
	if [ -z "$selected_mangohud" ]; then exit 0; fi

	mangohud_short_name=$(if [ "''${selected_mangohud}" != "Horizontal" ] && [ "''${selected_mangohud}" != "Vertical" ]; then echo "disabled"; else echo "''${selected_mangohud}" | tr '[:upper:]' '[:lower:]'; fi)

	if ${pkgs.coreutils}/bin/test "x$(id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${mangohud_short_name}" || { if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_fr}" --error --ok-label="''${exit_label_fr}" --text "''${error_pkexec_fr}"; else ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_en}" --error --ok-label="''${exit_label_en}" --text "''${error_pkexec_en}"; fi; exit 1; }
	fi

else

	if ${pkgs.coreutils}/bin/test "x$(id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${1}" || { if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_fr}" --error --ok-label="''${exit_label_fr}" --text "''${error_pkexec_fr}"; else ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_en}" --error --ok-label="''${exit_label_en}" --text "''${error_pkexec_en}"; fi; exit 1; }
	fi

	current_mangohud=$(if ${pkgs.gnugrep}/bin/grep -q 'glf.mangohud.configuration =' /etc/nixos/configuration.nix; then ${pkgs.gnugrep}/bin/grep 'glf.mangohud.configuration =' /etc/nixos/configuration.nix | ${pkgs.gnugrep}/bin/grep -o '"[^"]\+"' | sed 's/"//g'; else echo ""; fi)
	if [ "''${current_mangohud}" != "disabled" ] && [ "''${current_mangohud}" != "horizontal" ] && [ "''${current_mangohud}" != "vertical" ]; then current_mangohud="horizontal"; fi
	
	if ${pkgs.gnugrep}/bin/grep -q 'glf.mangohud.configuration = ".*";' /etc/nixos/configuration.nix; then
		${pkgs.gnused}/bin/sed -i "s@glf.mangohud.configuration = \".*\";@glf.mangohud.configuration = \"''${1}\";@g" /etc/nixos/configuration.nix
	else
		${pkgs.gnused}/bin/sed -i "s/^}$/  glf.mangohud.configuration = \"''${1}\";\n}/g" /etc/nixos/configuration.nix
	fi

	${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake /etc/nixos#GLF-OS --show-trace || { ${pkgs.gnused}/bin/sed -i "s@glf.mangohud.configuration = \".*\";@glf.mangohud.configuration = \"''${current_mangohud}\";@g" /etc/nixos/configuration.nix; if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_fr}" --error --ok-label="''${exit_label_fr}" --text "''${error_text_fr}"; else ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_en}" --error --ok-label="''${exit_label_en}" --text "''${error_text_en}"; fi; exit 1; }

	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_fr}" --info --ok-label="''${exit_label_fr}" --text "''${reboot_text_fr}"
	else
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${mangohud_title_en}" --info --ok-label="''${exit_label_en}" --text "''${reboot_text_en}"
	fi

fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "GLF-OS MangoHud Configuration";
      icon = "glfos-logo";
      exec = "${script}/bin/${name}";
      terminal = true;
      categories = ["System"];
    };
  in ''
    mkdir -p $out/bin
    cp ${script}/bin/${name} $out/bin
    mkdir -p $out/share/applications
    cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';
  dontBuild = true;
}

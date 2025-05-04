{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "glfos-environment-selection";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      runtimeInputs = with pkgs; [ coreutils gnused zenity ];
      text = ''
set +o nounset
set -e

error_display_fr="Erreur: La variable d'environnement DISPLAY n'a pas été trouvée, assurez-vous de lancer cette application depuis un environnement de bureau."
error_internet_fr="Erreur: Aucune connection internet n'est disponible."
error_arguments1_fr="Erreur: Les paramètres d'environnement et / ou d'édition GLF-OS ne sont pas valides."
error_arguments2_fr="Erreur: Veuillez spécifier l'environnement et l'édition GLF-OS."
environment_title_fr="GLF-OS - Interface de sélection de l'environnement"
environment_text_fr="Bienvenue dans l'interface de sélection de l'environnement.\n\nQuel environnement de GLF-OS souhaitez-vous utiliser ?\n\nAttention: changer d'environnement remettra à zéro vos paramètres dconf et gtk.\n"
environment_column_fr="Environement"
environment_ok_label_fr="Suivant"
exit_label_fr="Quitter"
edition_title_fr="GLF-OS - Interface de sélection de l'environnement"
edition_text_fr="Quelle édition de GLF-OS souhaitez-vous utiliser ?"
edition_column_fr="Edition"
edition_ok_label_fr="Appliquer"
progress_text_fr="Reconstruction du système, veuillez patienter..."
error_text_fr="Erreur: GLF-OS n'a pas pu être mis à jour."
reboot_text_fr="Le système a été mis à jour. Les changements prendront effet au prochain démarrage."

error_display_en="Error: DISPLAY env variable was not found, please make sure you run this program from a desktop environment."
error_internet_en="Error: Internet connection is not available."
error_arguments1_en="Error: GLF-OS environment and / or edition parameters are not valid."
error_arguments2_en="Error: Please specify both GLF-OS environment and edition."
environment_title_en="GLF-OS - Environment selection interface"
environment_text_en="Welcome to the environment selection interface.\n\nWhich environment of GLF-OS would you like to use ?\n\nWarning: changing the environment will reset your dconf and gtk settings.\n"
environment_column_en="Environment"
environment_ok_label_en="Next"
exit_label_en="Exit"
edition_title_en="GLF-OS - Environment selection interface"
edition_text_en="Which GLF-OS edition would you like to use ?"
edition_column_en="Edition"
edition_ok_label_en="Apply"
progress_text_en="Rebuilding system, please wait..."
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
		${pkgs.zenity}/bin/zenity --width=640 --title="''${environment_title_fr}" --error --ok-label="''${exit_label_fr}" --text "''${error_internet_fr}" 2>/dev/null
		exit 1
	else
		${pkgs.zenity}/bin/zenity --width=640 --title="''${environment_title_en}" --error --ok-label="''${exit_label_en}" --text "''${error_internet_en}" 2>/dev/null
		exit 1
	fi
fi

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 2 ]; then
	if { [ "''${1}" != "gnome" ] && [ "''${1}" != "plasma" ]; } || { [ "''${2}" != "standard" ] && [ "''${2}" != "mini" ] && [ "''${2}" != "studio" ] && [ "''${2}" != "studio-pro" ]; }; then
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
else
	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		read -rp "''${error_arguments2_fr}"
		exit 1
	else
		read -rp "''${error_arguments2_en}"
		exit 1
	fi
fi

if [ "''${interface}" -eq 1 ]; then

	environment_options=( "Gnome" "Plasma" )
	edition_options=( "Standard" "Mini" "Studio" "Studio | DaVinci Resolve Pro" )

	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		selected_environment=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="''${environment_title_fr}" --list --text "''${environment_text_fr}" --column "''${environment_column_fr}" "''${environment_options[@]}" --ok-label="''${environment_ok_label_fr}" --cancel-label="''${exit_label_fr}" 2>/dev/null)
		selected_edition=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="''${edition_title_fr}" --list --text "''${edition_text_fr}" --column "''${edition_column_fr}" "''${edition_options[@]}" --ok-label="''${edition_ok_label_fr}" --cancel-label="''${exit_label_fr}" 2>/dev/null)
	else
		selected_environment=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="''${environment_title_en}" --list --text "''${environment_text_en}" --column "''${environment_column_en}" "''${environment_options[@]}" --ok-label="''${environment_ok_label_en}" --cancel-label="''${exit_label_en}" 2>/dev/null)
		selected_edition=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="''${edition_title_en}" --list --text "''${edition_text_en}" --column "''${edition_column_en}" "''${edition_options[@]}" --ok-label="''${edition_ok_label_en}" --cancel-label="''${exit_label_en}" 2>/dev/null)
	fi
	if [ -z "$selected_environment" ]; then exit 0; fi

	case $selected_environment in
		'Gnome')
			environment_short_name="gnome"
		;;
		'Plasma')
			environment_short_name="plasma"
		;;
	esac

	case $selected_edition in
		'Standard')
			edition_short_name="standard"
		;;
		'Mini')
			edition_short_name="mini"
		;;
		'Studio')
			edition_short_name="studio"
		;;
		'Studio | DaVinci Resolve Pro')
			edition_short_name="studio-pro"
		;;
	esac

	if ${pkgs.coreutils}/bin/test "x$(id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${environment_short_name}" "''${edition_short_name}"
	fi

else

	if ${pkgs.coreutils}/bin/test "x$(id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${1}" "''${2}"
	fi

	current_environment=$(if ${pkgs.gnugrep}/bin/grep -q 'glf.environment.type =' /etc/nixos/configuration.nix; then ${pkgs.gnugrep}/bin/grep 'glf.environment.type =' /etc/nixos/configuration.nix | ${pkgs.gnugrep}/bin/grep -o '"[^"]\+"' | sed 's/"//g'; else echo ""; fi)
	current_edition=$(if ${pkgs.gnugrep}/bin/grep -q 'glf.environment.edition =' /etc/nixos/configuration.nix; then ${pkgs.gnugrep}/bin/grep 'glf.environment.edition =' /etc/nixos/configuration.nix | ${pkgs.gnugrep}/bin/grep -o '"[^"]\+"' | sed 's/"//g'; else echo ""; fi)
	if [ "''${current_environment}" != "gnome" ] && [ "''${current_environment}" != "plasma" ]; then current_environment="gnome"; fi
	if [ "''${current_edition}" != "standard" ] && [ "''${current_edition}" != "mini" ] && [ "''${current_edition}" != "studio" ] && [ "''${current_edition}" != "studio-pro" ]; then current_edition="standard"; fi
	
	if ${pkgs.gnugrep}/bin/grep -q 'glf.environment.type = ".*";' /etc/nixos/configuration.nix; then
		${pkgs.gnused}/bin/sed -i "s@glf.environment.type = \".*\";@glf.environment.type = \"''${1}\";@g" /etc/nixos/configuration.nix
		${pkgs.gnused}/bin/sed -i "s@glf.environment.edition = \".*\";@glf.environment.edition = \"''${2}\";@g" /etc/nixos/configuration.nix
	else
		${pkgs.gnused}/bin/sed -i "/services.xserver.desktopManager./d" /etc/nixos/configuration.nix
		${pkgs.gnused}/bin/sed -i "/services.xserver.displayManager./d" /etc/nixos/configuration.nix
		${pkgs.gnused}/bin/sed -i "s/^}$/  glf.environment.type = \"''${1}\";\n}/g" /etc/nixos/configuration.nix
		${pkgs.gnused}/bin/sed -i "s/^}$/  glf.environment.edition = \"''${2}\";\n}/g" /etc/nixos/configuration.nix
	fi

	${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake /etc/nixos#GLF-OS --show-trace > >(if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then zenity --width=640 --title="''${environment_title_fr}" --text="''${progress_text_fr}" --progress --pulsate --no-cancel --auto-close 2>/dev/null; else zenity --width=640 --title="''${environment_title_en}" --text="''${progress_text_en}" --progress --pulsate --no-cancel --auto-close 2>/dev/null; fi) || { ${pkgs.gnused}/bin/sed -i "s@glf.environment.type = \".*\";@glf.environment.type = \"''${current_environment}\";@g" /etc/nixos/configuration.nix; ${pkgs.gnused}/bin/sed -i "s@glf.environment.edition = \".*\";@glf.environment.edition = \"''${current_edition}\";@g" /etc/nixos/configuration.nix; if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${environment_title_fr}" --error --ok-label="''${exit_label_fr}" --text "''${error_text_fr}" 2>/dev/null; else ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${environment_title_en}" --error --ok-label="''${exit_label_en}" --text "''${error_text_en}" 2>/dev/null; fi; exit 1; }

	if [ "''${current_environment}" != "''${1}" ]; then
		for gtkconfig in /home/*/.gtkrc* /home/*/.config/gtkrc* /home/*/.config/gtk-* /home/*/.config/dconf; do ${pkgs.coreutils}/bin/rm -rf "''${gtkconfig}"; done
	fi

	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${environment_title_fr}" --info --ok-label="''${exit_label_fr}" --text "''${reboot_text_fr}" 2>/dev/null
	else
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=640 --title="''${environment_title_en}" --info --ok-label="''${exit_label_en}" --text "''${reboot_text_en}" 2>/dev/null
	fi

fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "GLF-OS Environment Selection";
      icon = "glfos-logo";
      exec = "${script}/bin/${name}";
      terminal = false;
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

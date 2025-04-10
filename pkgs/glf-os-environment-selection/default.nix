{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "glf-os-environment-selection";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      runtimeInputs = with pkgs; [ coreutils gnused zenity ];
      text = ''
set +o nounset
set -e

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 2 ]; then
	if { [ "''${1}" != "gnome" ] && [ "''${1}" != "plasma" ]; } || { [ "''${2}" != "standard" ] && [ "''${2}" != "mini" ] && [ "''${2}" != "studio" ] && [ "''${2}" != "studio-pro" ]; }; then
		echo "Error: GLF-OS environment and / or edition parameters are not valid."
		exit 1
	else
		interface=0
	fi
else
	echo "Error: Please specify both GLF-OS environment and edition."
fi

environment_title_fr="GLF-OS - Interface de sélection de l'environnement"
environment_text_fr="Bienvenue dans l'interface de sélection de l'environnement.\n\nQuel environnement de GLF-OS souhaitez-vous utiliser ?"
environment_column1_fr="Sélection"
environment_column2_fr="Environement"
environment_ok_label_fr="Suivant"
environment_cancel_label_fr="Quitter"
edition_title_fr="GLF-OS - Interface de sélection de l'environnement"
edition_text_fr="Quelle édition de GLF-OS souhaitez-vous utiliser ?"
edition_column1_fr="Sélection"
edition_column2_fr="Edition"
edition_ok_label_fr="Appliquer"
edition_cancel_label_fr="Quitter"
reboot_text_fr="Le système a été mis à jour. Les changements prendront effet au prochain démarrage."

environment_title_en="GLF-OS - Environment selection interface"
environment_text_en="Welcome to the environment selection interface.\n\nWhich environment of GLF-OS would you like to use ?\n"
environment_column1_en="Selection"
environment_column2_en="Environment"
environment_ok_label_en="Next"
environment_cancel_label_en="Exit"
edition_title_en="GLF-OS - Environment selection interface"
edition_text_en="Which GLF-OS edition would you like to use ?"
edition_column1_en="Selection"
edition_column2_en="Edition"
edition_ok_label_en="Apply"
edition_cancel_label_en="Exit"
reboot_text_en="The system has been updated. Changes will be applied on the next boot."

if [ "''${interface}" -eq 1 ]; then

	environment_options=( "FALSE" "Gnome" "FALSE" "Plasma" )
	edition_options=( "FALSE" "Standard" "FALSE" "Mini" "FALSE" "Studio" "FALSE" "Studio | DaVinci Resolve Pro" )

	locale="$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)"
	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		selected_environment=$(zenity --height=480 --width=640 --title="''${environment_title_fr}" --list --radiolist --text "''${environment_text_fr}" --column "''${environment_column1_fr}" --column "''${environment_column2_fr}" "''${environment_options[@]}" --ok-label="''${environment_ok_label_fr}" --cancel-label="''${environment_cancel_label_fr}" 2>/dev/null)
		selected_edition=$(zenity --height=480 --width=640 --title="''${edition_title_fr}" --list --radiolist --text "''${edition_text_fr}" --column "''${edition_column1_fr}" --column "''${edition_column2_fr}" "''${edition_options[@]}" --ok-label="''${edition_ok_label_fr}" --cancel-label="''${edition_cancel_label_fr}" 2>/dev/null)
	else
		selected_environment=$(zenity --height=480 --width=640 --title="''${environment_title_en}" --list --radiolist --text "''${environment_text_en}" --column "''${environment_column1_en}" --column "''${environment_column2_en}" "''${environment_options[@]}" --ok-label="''${environment_ok_label_en}" --cancel-label="''${environment_cancel_label_en}" 2>/dev/null)
		selected_edition=$(zenity --height=480 --width=640 --title="''${edition_title_en}" --list --radiolist --text "''${edition_text_en}" --column "''${edition_column1_en}" --column "''${edition_column2_en}" "''${edition_options[@]}" --ok-label="''${edition_ok_label_en}" --cancel-label="''${edition_cancel_label_en}" 2>/dev/null)
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

	if test "x$(id -u)" != "x0"; then
		pkexec --disable-internal-agent "''${0}" "''${environment_short_name}" "''${edition_short_name}"
		status=$?
		exit $status
	fi

else

	if test "x$(id -u)" != "x0"; then
		pkexec --disable-internal-agent "''${0}" "''${1}" "''${2}"
		status=$?
		exit $status
	fi

	if grep -q 'glf.environment.type = ".*";' /etc/nixos/configuration.nix; then
		sed -i "s@glf.environment.type = \".*\";@glf.environment.type = \"''${1}\";@g" /etc/nixos/configuration.nix
		sed -i "s@glf.environment.edition = \".*\";@glf.environment.edition = \"''${2}\";@g" /etc/nixos/configuration.nix
	else
		sed -i "s/^}$/  glf.environment.type = \"''${1}\";\n}/g" /etc/nixos/configuration.nix
		sed -i "s/^}$/  glf.environment.edition = \"''${2}\";\n}/g" /etc/nixos/configuration.nix
	fi

	nixos-rebuild boot --flake /etc/nixos#GLF-OS
	
	for gtkconfig in /home/*/.gtkrc* /home/*/.config/gtkrc* /home/*/.config/gtk-* /home/*/.config/dconf; do rm -rf "''${gtkconfig}"; done
	
	echo ""
	locale="$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)"
	if [ -n "''${locale}" ] && [ "''${locale}" == "fr" ]; then
		read -rp "''${reboot_text_fr}"
	else
		read -rp "''${reboot_text_en}"
	fi

fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "GLF-OS Environment Selection";
      icon = "glf-os-icon";
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

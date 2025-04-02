#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#   SPDX-FileCopyrightText: 2022 Victor Fuentes <vmfuentes64@gmail.com>
#   SPDX-FileCopyrightText: 2019 Adriaan de Groot <groot@kde.org>
#   SPDX-License-Identifier: GPL-3.0-or-later
#
#   Calamares is Free Software: see the License-Identifier above.
# ------------------------------------------------------------------------------

import libcalamares
import os
import subprocess
import re
import tempfile
import shutil # Ajouté pour rmtree si nécessaire

import gettext

_ = gettext.translation(
    "calamares-python",
    localedir=libcalamares.utils.gettext_path(),
    languages=libcalamares.utils.gettext_languages(),
    fallback=True,
).gettext

# ====================================================
# Configuration.nix Templates
# ====================================================
# Signature changée : pas d'inputs ici, import de customConfig retiré (les modules viennent du flake)
cfghead = """{ config, pkgs, lib, ... }:
{
  # Options globales Nix si nécessaire (peuvent être dans le flake aussi)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Inclut seulement la configuration matérielle générée ici
      ./hardware-configuration.nix
      # Les modules GLF (gaming, gnome, etc.) sont importés via ./modules/default
      # qui est inclus par le flake.nix dans /etc/nixos
    ];

  # Le reste de la configuration (utilisateur, locale, bootloader, etc.)
  # est ajouté ci-dessous par le script.
"""

# ... (gardez tous les autres templates cfg_nvidia, cfgbootefi, etc. inchangés) ...
cfg_nvidia = """  glf.nvidia_config = {
    enable = true;
    laptop = @@has_laptop@@;
@@prime_busids@@  };

"""

cfgbootefi = """  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiInstallAsRemovable = true;
"""

cfgbootbios = """  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "@@bootdev@@";
  boot.loader.grub.useOSProber = true;

"""

cfgbootnone = """  # Disable bootloader.
  boot.loader.grub.enable = false;

"""

cfgbootgrubcrypt = """  # Setup keyfile
  boot.initrd.secrets = {
    "/boot/crypto_keyfile.bin" = null;
  };
  boot.loader.grub.enableCryptodisk = true;

"""

cfgnetwork = """  networking.hostName = "@@hostname@@"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

"""

cfgnetworkmanager = """  # Enable networking
  networking.networkmanager.enable = true;

"""

cfgtime = """  # Set your time zone.
  time.timeZone = "@@timezone@@";

"""

cfglocale = """  # Select internationalisation properties.
  i18n.defaultLocale = "@@LANG@@";

"""

cfglocaleextra = """  i18n.extraLocaleSettings = {
    LC_ADDRESS = "@@LC_ADDRESS@@";
    LC_IDENTIFICATION = "@@LC_IDENTIFICATION@@";
    LC_MEASUREMENT = "@@LC_MEASUREMENT@@";
    LC_MONETARY = "@@LC_MONETARY@@";
    LC_NAME = "@@LC_NAME@@";
    LC_NUMERIC = "@@LC_NUMERIC@@";
    LC_PAPER = "@@LC_PAPER@@";
    LC_TELEPHONE = "@@LC_TELEPHONE@@";
    LC_TIME = "@@LC_TIME@@";
  };

"""

cfggnome = """  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.excludePackages = [ pkgs.xterm ];


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

"""

cfgkeymap = """  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "@@kblayout@@";
    variant = "@@kbvariant@@";
  };

"""
cfgconsole = """  # Configure console keymap
  console.keyMap = "@@vconsole@@";

"""

cfgusers = """  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.@@username@@ = {
    isNormalUser = true;
    description = "@@fullname@@";
    extraGroups = [ @@groups@@ ];
  };

"""

cfgautologin = """  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "@@username@@";

"""

cfgautologingdm = """  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

"""

cfgautologintty = """  # Enable automatic login for the user.
  services.getty.autologinUser = "@@username@@";

"""

cfgtail = """
  system.stateVersion = "@@nixosversion@@"; # DO NOT TOUCH
}
"""


# =================================================
# Required functions (inchangées)
# =================================================
def env_is_set(name):
    envValue = os.environ.get(name)
    return not (envValue is None or envValue == "")

def generateProxyStrings():
    proxyEnv = []
    if env_is_set('http_proxy'):
        proxyEnv.append('http_proxy={}'.format(os.environ.get('http_proxy')))
    if env_is_set('https_proxy'):
        proxyEnv.append('https_proxy={}'.format(os.environ.get('https_proxy')))
    if env_is_set('HTTP_PROXY'):
        proxyEnv.append('HTTP_PROXY={}'.format(os.environ.get('HTTP_PROXY')))
    if env_is_set('HTTPS_PROXY'):
        proxyEnv.append('HTTPS_PROXY={}'.format(os.environ.get('HTTPS_PROXY')))

    if len(proxyEnv) > 0:
        proxyEnv.insert(0, "env")

    return proxyEnv

def pretty_name():
    return _("Installing GLF-OS.")

status = pretty_name()

def pretty_status_message():
    return status

def catenate(d, key, *values):
    if [v for v in values if v is None]:
        return
    d[key] = "".join(values)

# ... (gardez les fonctions de détection Nvidia inchangées) ...
def get_vga_devices():
    result = subprocess.run(['lspci'], stdout=subprocess.PIPE, text=True)
    lines = result.stdout.strip().splitlines()
    vga_devices = []
    keywords = [' VGA compatible controller: ', ' 3D controller: ']
    for line in lines:
        for k in keywords:
            if k in line:
                address, description = line.split(k, 1)
                pci_address = convert_to_pci_format(address)
                if pci_address != "":
                    vga_devices.append((pci_address, description))
                break
    return vga_devices

def convert_to_pci_format(address):
    devid = re.split(r"[:\.]", address)
    if len(devid) < 3:
        return ""
    bus = devid[-3]
    device = devid[-2]
    function = devid[-1]
    return f"PCI:{int(bus, 16)}:{int(device, 16)}:{int(function)}"

def has_nvidia_device(vga_devices):
    for pci_address, description in vga_devices:
        if "nvidia" in description.lower():
            return True
    return False

def has_nvidia_laptop(vga_devices):
    for pci_address, description in vga_devices:
        dev_desc = description.lower()
        keywords = ['laptop', 'mobile']
        pattern = r'\b\d{3}M\b'  # three digits followed by 'M'
        if "nvidia" in dev_desc:
            for k in keywords:
                if k in dev_desc:
                    return True
            if re.search(pattern, description):
                return True
    return False

def generate_prime_entries(vga_devices):
    output_lines = ""
    for pci_address, description in vga_devices:
        if "intel" in description.lower():
            var_name = "intelBusId"
        elif "nvidia" in description.lower():
            var_name = "nvidiaBusId"
        elif "amd" in description.lower():
            var_name = "amdgpuBusId"
        else:
            continue
        output_lines += f"    # {description}\n"
        output_lines += f"    {var_name} = \"{pci_address}\";\n"
    return output_lines


# ==================================================================================================
# GLF-OS Install function - Execution start here
# ==================================================================================================
def run():
    """NixOS Configuration."""

    global status
    status = _("Configuring NixOS")
    libcalamares.job.setprogress(0.1)

    # Create initial config string variable
    cfg = cfghead
    gs = libcalamares.globalstorage
    variables = dict()

    # Nvidia support
    vga_devices = get_vga_devices()
    has_nvidia = has_nvidia_device(vga_devices)
    if has_nvidia == True:
        cfg += cfg_nvidia
        has_laptop = has_nvidia_laptop(vga_devices)
        catenate(variables, "has_laptop", f"{has_laptop}".lower() )
        catenate(variables, "prime_busids", generate_prime_entries(vga_devices) )

    # Setup variables
    root_mount_point = gs.value("rootMountPoint")
    # Le fichier de config principal qui sera généré
    main_config_on_target = os.path.join(root_mount_point, "etc/nixos/configuration.nix")
    # Le fichier hardware config qui sera généré puis restauré
    hw_cfg_dest = os.path.join(root_mount_point, "etc/nixos/hardware-configuration.nix")
    # Le répertoire /etc/nixos sur la cible
    nixos_etc_on_target = os.path.join(root_mount_point, "etc/nixos")

    fw_type = gs.value("firmwareType")
    bootdev = (
        "nodev"
        if gs.value("bootLoader") is None
        else gs.value("bootLoader")["installPath"]
    )

    # ================================================================================
    # Bootloader Configuration (inchangé)
    # ================================================================================
    # Check bootloader
    if fw_type == "efi":
        cfg += cfgbootefi
        catenate(variables, "bootdev", bootdev) # bootdev est "nodev" ici mais gardé pour cohérence
    elif bootdev != "nodev":
        cfg += cfgbootbios
        catenate(variables, "bootdev", bootdev)
    else:
        cfg += cfgbootnone

    # ================================================================================
    # LUKS Configuration (inchangé)
    # ================================================================================
    # ... (gardez toute la logique LUKS telle quelle) ...
    for part in gs.value("partitions"):
        if (
            part["claimed"] is True
            and (part["fsName"] == "luks" or part["fsName"] == "luks2")
            and part["device"] is not None
            and part["fs"] == "linuxswap"
        ):
            cfg += """  boot.initrd.luks.devices."{}".device = "/dev/disk/by-uuid/{}";\n""".format(part["luksMapperName"], part["uuid"])

    root_is_encrypted = False
    boot_is_encrypted = False
    boot_is_partition = False

    for part in gs.value("partitions"):
        if part["mountPoint"] == "/":
            root_is_encrypted = part["fsName"] in ["luks", "luks2"]
        elif part["mountPoint"] == "/boot":
            boot_is_partition = True
            boot_is_encrypted = part["fsName"] in ["luks", "luks2"]

    if fw_type != "efi" and (
        (boot_is_partition and boot_is_encrypted)
        or (root_is_encrypted and not boot_is_partition)
    ):
        cfg += cfgbootgrubcrypt
        status = _("Setting up LUKS")
        libcalamares.job.setprogress(0.15)
        try:
            libcalamares.utils.host_env_process_output(
                ["mkdir", "-p", root_mount_point + "/boot"], None
            )
            libcalamares.utils.host_env_process_output(
                ["chmod", "0700", root_mount_point + "/boot"], None
            )
            libcalamares.utils.host_env_process_output(
                [
                    "dd", "bs=512", "count=4", "if=/dev/random",
                    "of=" + root_mount_point + "/boot/crypto_keyfile.bin",
                    "iflag=fullblock",
                ], None,
            )
            libcalamares.utils.host_env_process_output(
                ["chmod", "600", root_mount_point + "/boot/crypto_keyfile.bin"], None
            )
        except subprocess.CalledProcessError:
            libcalamares.utils.error("Failed to create /boot/crypto_keyfile.bin")
            return (
                _("Failed to create /boot/crypto_keyfile.bin"),
                _("Check if you have enough free space on your partition."),
            )

        for part in gs.value("partitions"):
            if (
                part["claimed"] is True
                and (part["fsName"] == "luks" or part["fsName"] == "luks2")
                and part["device"] is not None
            ):
                cfg += """  boot.initrd.luks.devices."{}".keyFile = "/boot/crypto_keyfile.bin";\n""".format(part["luksMapperName"])
                try:
                    libcalamares.utils.host_env_process_output(
                        [ "cryptsetup", "luksConvertKey", "--hash", "sha256", "--pbkdf", "pbkdf2", part["device"], ],
                        None, part["luksPassphrase"],
                    )
                    libcalamares.utils.host_env_process_output(
                        [ "cryptsetup", "luksAddKey", "--hash", "sha256", "--pbkdf", "pbkdf2", part["device"],
                          root_mount_point + "/boot/crypto_keyfile.bin", ],
                        None, part["luksPassphrase"],
                    )
                except subprocess.CalledProcessError:
                    libcalamares.utils.error(f"Failed to add {part['luksMapperName']} to /boot/crypto_keyfile.bin")
                    return (_("cryptsetup failed"), _(f"Failed to add {part['luksMapperName']} to /boot/crypto_keyfile.bin"))


    # ================================================================================
    # Assemble final part of configuration.nix string (inchangé)
    # ================================================================================
    status = _("Configuring NixOS")
    libcalamares.job.setprogress(0.18)

    # Network
    cfg += cfgnetwork
    cfg += cfgnetworkmanager

    # Hostname (Utilise @@hostname@@ qui sera remplacé plus bas)
    # Note: la valeur par défaut est maintenant dans cfgnetwork
    # if gs.value("hostname") is None:
    #    catenate(variables, "hostname", "GLF-OS") # Default set in cfgnetwork
    # else:
    catenate(variables, "hostname", gs.value("hostname") or "GLF-OS") # Use default if None

    # Internationalisation properties
    if gs.value("locationRegion") is not None and gs.value("locationZone") is not None:
        cfg += cfgtime
        catenate(variables, "timezone", gs.value("locationRegion"), "/", gs.value("locationZone"))
    if gs.value("localeConf") is not None:
        localeconf = gs.value("localeConf")
        locale = localeconf.pop("LANG").split("/")[0]
        cfg += cfglocale
        catenate(variables, "LANG", locale)
        if (len(set(localeconf.values())) != 1 or list(set(localeconf.values()))[0] != locale):
            cfg += cfglocaleextra
            for conf in localeconf:
                catenate(variables, conf, localeconf.get(conf).split("/")[0])

    # Desktop environment (GNOME est ajouté ici, mais pourrait être dans les modules de base)
    if gs.value("packagechooser_packagechooser") == "gnome":
        cfg += cfggnome

    # Keyboard layout settings
    if (gs.value("keyboardLayout") is not None and gs.value("keyboardVariant") is not None):
        cfg += cfgkeymap
        catenate(variables, "kblayout", gs.value("keyboardLayout"))
        catenate(variables, "kbvariant", gs.value("keyboardVariant"))
        # ... (la logique pour vconsole reste la même) ...
        if gs.value("keyboardVConsoleKeymap") is not None:
            try:
                subprocess.check_output(["pkexec", "loadkeys", gs.value("keyboardVConsoleKeymap").strip()], stderr=subprocess.STDOUT,)
                cfg += cfgconsole
                catenate(variables, "vconsole", gs.value("keyboardVConsoleKeymap").strip())
            except subprocess.CalledProcessError as e:
                libcalamares.utils.error(f"loadkeys: {e.output}")
                libcalamares.utils.error(f"Setting vconsole keymap to {gs.value('keyboardVConsoleKeymap').strip()} will fail, using default")
        else:
            # ... (la logique pour deviner vconsole reste la même) ...
            try:
                kbdmodelmap = open("/run/current-system/sw/share/systemd/kbd-model-map", "r")
                kbd = kbdmodelmap.readlines()
                kbdmodelmap.close() # Fermer le fichier
                out = []
                for line in kbd:
                    if line.startswith("#"): continue
                    out.append(line.split())
                find = []
                for row in out:
                    if gs.value("keyboardLayout") == row[1]: find.append(row)
                if find: vconsole = find[0][0]
                else: vconsole = ""
                variant = gs.value("keyboardVariant") or "-"
                for row in find:
                    if len(row) > 3 and variant in row[3]: # Vérifier la longueur de la ligne
                        vconsole = row[0]; break
                if vconsole and vconsole != "us":
                    try:
                        subprocess.check_output(["pkexec", "loadkeys", vconsole], stderr=subprocess.STDOUT)
                        cfg += cfgconsole
                        catenate(variables, "vconsole", vconsole)
                    except subprocess.CalledProcessError as e:
                         libcalamares.utils.error(f"loadkeys: {e.output}")
                         libcalamares.utils.error(f"vconsole value: {vconsole}")
                         libcalamares.utils.error(f"Setting vconsole keymap to {gs.value('keyboardVConsoleKeymap')} will fail, using default")
            except Exception as e:
                 libcalamares.utils.error(f"Error guessing vconsole keymap: {e}")


    # Setup user
    if gs.value("username") is not None:
        fullname = gs.value("fullname")
        groups = ["networkmanager", "wheel", "scanner", "lp", "disk", "audio", "video", "input"] # Ajout groupes courants
        cfg += cfgusers
        catenate(variables, "username", gs.value("username"))
        catenate(variables, "fullname", fullname)
        catenate(variables, "groups", (" ").join(['"' + s + '"' for s in groups]))
        # ... (logique autologin inchangée) ...
        if (gs.value("autoLoginUser") is not None and gs.value("packagechooser_packagechooser") is not None and gs.value("packagechooser_packagechooser") != ""):
            cfg += cfgautologin
            if gs.value("packagechooser_packagechooser") == "gnome":
                cfg += cfgautologingdm
        elif gs.value("autoLoginUser") is not None:
            cfg += cfgautologintty


    # Set System version
    cfg += cfgtail
    try:
        # Essayer d'obtenir la version depuis /etc/os-release sur le système live
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("NIXOS_VERSION_ID="):
                    version = line.strip().split("=")[1].strip('"')
                    # Garder seulement les deux premiers composants (e.g., "24.11")
                    version = ".".join(version.split(".")[:2])
                    break
            else: # Si la boucle finit sans break
                 version = "24.11" # Valeur par défaut si non trouvé
    except FileNotFoundError:
         version = "24.11" # Valeur par défaut si /etc/os-release n'existe pas
    catenate(variables, "nixosversion", version)


    # Check variables (inchangé)
    # ...

    # Do substitutions (inchangé)
    for key in variables.keys():
        pattern = "@@{key}@@".format(key=key)
        cfg = cfg.replace(pattern, str(variables[key]))

    status = _("Generating NixOS configuration")
    libcalamares.job.setprogress(0.25)

    # ========================================================================================
    # Generate hardware config & Prepare Target Directory (MODIFIÉ)
    # ========================================================================================
    temp_filepath = "" # Définir au cas où l'exception se produit avant l'assignation
    hw_cfg_content = None # Définir pour savoir si on a lu le fichier
    try:
        # 1. Generate hardware.nix
        libcalamares.utils.debug("Generating hardware configuration...")
        subprocess.check_output(
            ["pkexec", "nixos-generate-config", "--no-filesystems", "--root", root_mount_point], # --no-filesystems ici
            stderr=subprocess.STDOUT,
        )
        # Lire le contenu immédiatement après la génération
        if os.path.exists(hw_cfg_dest):
            libcalamares.utils.debug(f"Reading generated hardware config: {hw_cfg_dest}")
            with open(hw_cfg_dest, "r") as hf:
                hw_cfg_content = hf.read()
        else:
             libcalamares.utils.warning(f"Generated hardware config not found after generation: {hw_cfg_dest}")

        # 2. Ensure target directory exists
        libcalamares.utils.debug(f"Ensuring target directory exists: {nixos_etc_on_target}")
        libcalamares.utils.host_env_process_output(["mkdir", "-p", nixos_etc_on_target], None)

        # 3. Copy essentials from /iso/iso-cfg/
        #    (flake.nix, flake.lock)
        iso_cfg_dir_on_iso = "/iso/iso-cfg"
        files_to_copy_from_iso_cfg = ["flake.nix", "flake.lock"] # Ne copie plus customConfig
        libcalamares.utils.debug(f"Copying flake files from {iso_cfg_dir_on_iso} to {nixos_etc_on_target}")
        for filename in files_to_copy_from_iso_cfg:
            src_file = os.path.join(iso_cfg_dir_on_iso, filename)
            if os.path.exists(src_file):
                 libcalamares.utils.host_env_process_output(["cp", src_file, nixos_etc_on_target], None)
                 libcalamares.utils.debug(f"Copied file {src_file} to {nixos_etc_on_target}")
            else:
                 libcalamares.utils.error(f"CRITICAL: Source file {src_file} not found on ISO!")
                 return (_("ISO Build Error"), f"Missing {filename} in /iso/iso-cfg on ISO.")

        # 4. Copy the GLF modules from /iso-modules/ to /mnt/etc/nixos/modules/
        modules_dir_on_iso = "/iso-modules"
        modules_dir_on_target = os.path.join(nixos_etc_on_target, "modules")
        libcalamares.utils.debug(f"Copying modules from {modules_dir_on_iso} to {modules_dir_on_target}")
        if os.path.isdir(modules_dir_on_iso):
            libcalamares.utils.host_env_process_output(["mkdir", "-p", modules_dir_on_target], None)
            # Utiliser rsync ou cp -aT pour mieux gérer les permissions/liens symboliques potentiels
            # cp -rT copie le contenu de la source dans la destination
            libcalamares.utils.host_env_process_output(["cp", "-aT", modules_dir_on_iso, modules_dir_on_target], None)
            libcalamares.utils.debug(f"Copied contents of {modules_dir_on_iso} to {modules_dir_on_target}")
        else:
             libcalamares.utils.error(f"CRITICAL: Source directory {modules_dir_on_iso} not found on ISO!")
             return (_("ISO Build Error"), f"Missing /iso-modules directory on ISO.")

        # 5. Write the main configuration.nix generated with templates
        libcalamares.utils.debug(f"Writing main configuration to {main_config_on_target}")
        # host_env_process_output ne fonctionne pas bien pour écrire un fichier directement
        # Écrire dans un fichier temporaire puis copier/déplacer avec sudo/pkexec
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".nix") as temp_cfg:
            temp_cfg.write(cfg)
            temp_filepath = temp_cfg.name
        libcalamares.utils.host_env_process_output(["mv", temp_filepath, main_config_on_target], None)
        libcalamares.utils.debug(f"Moved generated config to {main_config_on_target}")
        temp_filepath = "" # Reset temp_filepath as it's moved

        # 6. Restore the generated hardware-configuration.nix
        #    (Nécessaire car l'étape 5 l'a généré à nouveau avec --no-filesystems)
        #    (En fait, non, nixos-generate-config génère les deux fichiers, donc pas besoin de restaurer si on ne l'écrase pas)
        #    MAIS, il faut s'assurer que le configuration.nix généré n'écrase pas celui écrit juste avant.
        #    Solution: Ne PAS lancer nixos-generate-config ici, mais le faire AVANT de générer cfg
        #    Déplacé !

    except subprocess.CalledProcessError as e:
        libcalamares.utils.error(f"Error during file operations: {e} - Output: {e.output.decode('utf8', errors='ignore') if e.output else 'N/A'}")
        return ("Installation failed during file preparation", f"{e} - Output: {e.output.decode('utf8', errors='ignore') if e.output else 'N/A'}")
    except Exception as e:
        libcalamares.utils.error(f"Unexpected error during file preparation: {e}")
        return ("Unexpected error during file preparation", str(e))
    # finally: # Pas besoin ici car temp_filepath est géré dans le with ou reset
        # if temp_filepath and os.path.exists(temp_filepath):
        #      try: os.remove(temp_filepath)
        #      except OSError as e: libcalamares.utils.warning(f"Could not remove temporary file {temp_filepath}: {e}")


    # Bind /tmp directory (inchangé)
    tmpPath = os.path.join(root_mount_point, "tmp/")
    # ... mkdir, chmod, mount --bind ... (garder cette partie)
    libcalamares.utils.host_env_process_output(["mkdir", "-p", tmpPath])
    libcalamares.utils.host_env_process_output(["chmod", "1777", tmpPath]) # Utiliser 1777 pour /tmp
    libcalamares.utils.host_env_process_output(["mount", "--bind", "/tmp", tmpPath])


    # ========================================================================================
    # Install System with nixos-install (inchangé)
    # ========================================================================================
    status = _("Installing NixOS")
    libcalamares.job.setprogress(0.3)

    # build nixos-install command
    nixosInstallCmd = [ "pkexec" ]
    nixosInstallCmd.extend(generateProxyStrings())
    nixosInstallCmd.extend(
        [
            "nixos-install",
            "--no-root-passwd",
            "--flake",
            f"{nixos_etc_on_target}#GLF-OS", # Utilise le flake dans /mnt/etc/nixos
            "--root",
            root_mount_point
        ]
    )

    # Install customizations (inchangé)
    try:
        output = ""
        # Utiliser Popen pour streamer la sortie
        proc = subprocess.Popen(nixosInstallCmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1, universal_newlines=True)
        for line in proc.stdout:
            output += line
            # Log en debug pour éviter de polluer l'UI Calamares, sauf si erreur ?
            libcalamares.utils.debug("nixos-install: {}".format(line.strip()))
            # Mise à jour de la progression Calamares (optionnel, peut être complexe)
            # if "building..." in line: libcalamares.job.setprogress(0.4)
            # if "copying path" in line: libcalamares.job.setprogress(0.6)
            # if "installing boot loader" in line: libcalamares.job.setprogress(0.8)

        exit_code = proc.wait()
        if exit_code != 0:
            libcalamares.utils.error(f"nixos-install failed with code {exit_code}")
            # Renvoyer la sortie complète dans les détails de l'erreur
            return (_("nixos-install failed"), _(output))
    except Exception as e:
        # Capturer d'autres exceptions potentielles (ex: Popen échoue)
        libcalamares.utils.error(f"Exception during nixos-install execution: {e}")
        return (_("nixos-install failed"), _(f"Installation failed to complete due to exception: {e}"))

    # Si tout va bien
    return None

{ lib, stdenv, fetchFromGitHub, kernel, kmod, linuxConsoleTools }:

let
    moduledir = "lib/modules/${kernel.modDirVersion}/kernel/drivers/hid";
    version-info = builtins.fromJSON (builtins.readFile ./version.json);
in 
stdenv.mkDerivation rec {
    pname = version-info.repo;
    version = version-info.version;
    name = "${pname}-${version}-${kernel.modDirVersion}";

    src = fetchFromGitHub {
        owner = version-info.owner;
        repo = version-info.repo;
        rev = version-info.version;
        sha256 = version-info.sha256;
    };

    hardeningDisable = [ "pic" "format" ];
    nativeBuildInputs = kernel.moduleBuildDependencies;

    patchPhase = ''
        mkdir -p $out/lib/udev/rules.d
        mkdir -p $out/${moduledir}
        substituteInPlace Makefile --replace "/etc/udev/rules.d" "$out/lib/udev/rules.d"
        substituteInPlace fanatec.rules --replace "/usr/bin/evdev-joystick" "${linuxConsoleTools}/bin/evdev-joystick" --replace "/bin/sh" "${stdenv.shell}"
        sed -i '/depmod/d' Makefile
    '';

    makeFlags = [
        "KVERSION=${kernel.modDirVersion}"
        "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "MODULEDIR=$(out)/${moduledir}"
    ];
}

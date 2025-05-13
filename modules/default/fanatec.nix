{ stdenv, pkgs, lib, fetchFromGitHub, kmod, kernelPackages, breakpointHook}:

let
  kernel = kernelPackages.kernel;
in stdenv.mkDerivation rec {
  name = "hid-fanatecff-${version}-${kernel.version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "gotzl";
    repo = "hid-fanatecff";
    rev = "f4b80a3436c6adad7afbbe1739e5189a9a86dddb";
    sha256 = "12zp7y2filghvyjmq47krvqazdb5f63jd3jilbxhgf2919iy3zn1";
  };

  sourceRoot = "source";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [
    pkgs.linuxConsoleTools
  ];

  makeFlags = [
    "KVERSION=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "MODULEDIR=$(out)/lib/modules/${kernel.modDirVersion}"
  ];

  preInstallPhase = ''
    sed -i '/fanatec.rules/d' Makefile
    sed -i '/depmod/d' Makefile
    mkdir -p $out/lib/modules/${kernel.modDirVersion}
  '';
  postPhase = ''
    substituteInPlace fanatec.rules  --replace /usr/bin/evdev-joystick ${pkgs.linuxConsoleTools}/bin/evdev-joystick
    mkdir -p $out/lib/udev/rules.d
    cp fanatec.rules $out/lib/udev/rules.d/99-fanatec.rules
  '';
  preInstallPhases = ["preInstallPhase"];
  postPhases = ["postPhase"];

  meta = with lib; {
    description = "A kernel module that provides support for fanatec wheels and pedals";
    homepage = "https://github.com/gotzl/hid-fanatecff";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}

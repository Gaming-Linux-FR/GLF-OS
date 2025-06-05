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

     preBuild = ''
    substituteInPlace Makefile --replace-fail "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    sed -i '/depmod/d' Makefile
    sed -i "10i\\\trmmod hid-logitech 2> /dev/null || true" Makefile
    sed -i "11i\\\trmmod hid-logitech-new 2> /dev/null || true" Makefile
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KVERSION=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with lib; {
    description = "Experimental Logitech force feedback module for Linux";
    homepage = "https://github.com/berarma/new-lg4ff";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ matthiasbenaets ];
    platforms = platforms.linux;
    broken = stdenv.hostPlatform.isAarch64;
  };
}

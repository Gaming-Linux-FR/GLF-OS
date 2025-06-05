{
  stdenvNoCC,
  lib,
}:

stdenvNoCC.mkDerivation {
  pname = "plymouth-glfos";
  version = "1.0.0";

  src = ./plymouth;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plymouth/themes/glfos
    cp -r * $out/share/plymouth/themes/glfos/
    substituteInPlace $out/share/plymouth/themes/glfos/glfos.plymouth \
      --replace-fail "/usr/" "$out/"
    runHook postInstall
  '';

  meta = {
    description = "GLF-OS distro Plymouth Theme";
    homepage = "https://github.com/Gaming-Linux-FR/GLF-OS";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
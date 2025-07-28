{ pkgs ? import <nixpkgs> {} }:

let
  baseApp = pkgs.flutter.buildFlutterApplication {
    pname = "glfos_welcome_screen";
    version = "0.0.3";

    # Fetch your project source
        src = pkgs.fetchFromGitHub {
          owner = "imikado";
          repo = "glfos-welcome-screen";
          rev = "1.0.12";
          sha256 = "0piqdp1rswv6b4bqfp7475kd5z96kvx5kwhiqdjgh4r0q4xzn30a"; # Get via nix-prefetch-url or nix build error
        };

    flutterChannel = "stable";  # Can be "beta", "master", etc.

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      gtk4
      libadwaita
      libepoxy
      libxkbcommon
      glib
      cairo
      pango
      atk
    ];

    buildPhase = ''
      rm -rf build

      # Try to override RPATH in Flutter's cmake phase
    export CMAKE_BUILD_RPATH_USE_ORIGIN=ON
    export CMAKE_SKIP_BUILD_RPATH=OFF
    export CMAKE_INSTALL_RPATH="$out/lib"
    export CMAKE_BUILD_RPATH="$out/lib"
    export CMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE
    export CMAKE_INSTALL_RPATH_USE_ORIGIN=ON

      flutter build linux --release
    '';

    installPhase = ''
  mkdir -p $out/bin
  cp -r build/linux/x64/release/bundle/* $out/

  ln -s $out/glfos_welcome_screen $out/bin/glfos_welcome_screen

  # Remove bad /build RPATHs in shared libs
  for lib in $out/lib/*.so; do
    if patchelf --print-rpath "$lib" | grep -q "/build"; then
      echo "Fixing RPATH in $lib"
      patchelf --set-rpath "$out/lib" "$lib"
    fi
  done
'';

    strictDeps = true;


    autoPubspecLock = ./pubspec.lock;

    meta = with pkgs.lib; {
      description = "Welcome screen";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
in
# Override outputs to disable 'debug' output that causes build failure
baseApp.overrideAttrs (_: {
  outputs = [ "out" ];
})

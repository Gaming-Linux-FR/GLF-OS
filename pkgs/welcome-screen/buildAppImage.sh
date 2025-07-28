#!/usr/bin/env bash

# Clean up previous build
rm -rf /tmp/glfosWelcomeScreen.AppDir

# Build Flutter app for Linux
flutter build linux --release

# Create AppDir structure
mkdir -p /tmp/glfosWelcomeScreen.AppDir/usr/lib

set -euo pipefail
SEEN_LIBS=()  # <--- FIX: initialize this array

APP_BIN="build/linux/x64/release/bundle/glfos_welcome_screen"
DEST_DIR="/tmp/glfosWelcomeScreen.AppDir/usr/lib"

copy_lib() {
  local lib_path="$1"

  [[ "$lib_path" != /* || ! -f "$lib_path" ]] && return

  local lib_name
  lib_name=$(basename "$lib_path")
  local dest_path="$DEST_DIR/$lib_name"

  # Only include libraries that match your whitelist
  case "$lib_name" in
    libepoxy.so.*| \
    libgtk-3.so.*| \
    libadwaita-1.so.*| \
    libgraphite2.so.*| \
    libpangocairo-1.0.so.*| \
    libpango-1.0.so.*| \
    libatk-1.0.so.*| \
    libgdk-3.so.*| \
    libcairo.so.*| \
    libatk-bridge-2.0.so.*| \
    libpangoft2-1.0.so.*| \
    libpng16.so.*)
      ;;
    *)
      #echo "Skipping (not whitelisted): $lib_name"
      return
      ;;
  esac

  if [[ ! " ${SEEN_LIBS[*]} " =~ " ${lib_name} " ]]; then
    SEEN_LIBS+=("$lib_name")
    #echo "Copying $lib_name"
    cp "$lib_path" "$dest_path"

    # Recursively resolve whitelisted dependencies
    ldd "$lib_path" | while read -r line; do
      subdep=$(echo "$line" | grep -o '/[^ ]*' || true)
      if [[ -n "$subdep" && -f "$subdep" ]]; then
        copy_lib "$subdep"
      fi
    done
  fi
}




# Start with main binary
# Start with main binary: extract all valid absolute paths
ldd "$APP_BIN" | while read -r line; do
  lib_path=$(echo "$line" | grep -o '/[^ ]*' || true)
  if [[ -n "$lib_path" && -f "$lib_path" ]]; then
    copy_lib "$lib_path"
  fi
done



# Copy main bundle contents and AppImage metadata
cp -r build/linux/x64/release/bundle/* /tmp/glfosWelcomeScreen.AppDir/
cp assets/logo.png /tmp/glfosWelcomeScreen.AppDir/glfosWelcomeScreen.png
cp appImage/AppRun /tmp/glfosWelcomeScreen.AppDir/AppRun
chmod +x /tmp/glfosWelcomeScreen.AppDir/AppRun
cp appImage/glfosWelcomeScreen.desktop /tmp/glfosWelcomeScreen.AppDir/
mkdir -p /tmp/glfosWelcomeScreen.AppDir/usr/lib/flutter_assets
cp -r assets /tmp/glfosWelcomeScreen.AppDir/usr/lib/flutter_assets/

# Build the AppImage
appimagetool-x86_64.AppImage /tmp/glfosWelcomeScreen.AppDir
rm -f dist/Welcome_screen-x86_64.AppImage
mv Welcome_screen-x86_64.AppImage dist/

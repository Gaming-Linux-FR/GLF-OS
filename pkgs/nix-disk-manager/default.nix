{ pkgs }:
pkgs.flutter.buildFlutterApplication rec {
  pname = "nix-disk-manager";
  version = "1.3.1";
  src = pkgs.fetchgit {
    url = "https://codeberg.org/imikado/nix-disk-manager.git";
    tag = "${version}";
    sha256 = "sha256-JNQUxZdZ/paQb0XdwHe7kzxFQsnz167+FjFNEpq7Lp0=";
  };
  autoPubspecLock = "${src}/pubspec.lock";
  buildInputs = with pkgs; [ flutter dart zlib gtk3 pkg-config libtool libGL ];
}


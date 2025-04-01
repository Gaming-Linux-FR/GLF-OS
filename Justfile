# Justfile help
_default:
	@just --list

# Perform a iso & install
all: iso install

# Check configuration (nix flake check)
check:
	nix --extra-experimental-features "nix-command flakes" flake check --no-build

# Build configuration (nix build)
build:
	nix --extra-experimental-features "nix-command flakes" build -L .#nixosConfigurations.glf-installer.config.system.build.toplevel

# Build new iso
iso:
	nix --extra-experimental-features "nix-command flakes" build -L .#iso

# Build and run glf-os virtual machine
build-vm:
	nixos-rebuild build-vm -I nixos-config=./iso-cfg/configuration.nix && ./result/bin/run-glfos-vm

# Update packages (flake.lock)
update:
	nix --extra-experimental-features "nix-command flakes" flake update

# Clean local build (nix-collect-garbage)
clean:
	#!/usr/bin/env bash
	if [ -L "result" ]; then rm result; fi
	nix-collect-garbage
	if [ -d "iso" ]; then rm -r iso; fi

# Copy image and compute sha256sum
install:
	#!/usr/bin/env bash
		ISO_FILE=$(find result/iso -name "*.iso") # Trouve le fichier ISO généré par NixOS
	if [ -n "$ISO_FILE" ]; then
		echo "Found ISO: $ISO_FILE"
		cp "$ISO_FILE" "GGLF-OS-BETA-OMNISLASH_stable.iso" # Copie avec la nomination GLF OS
		sha256sum "GLF-OS-ALPHA-OMNISLASH_3.iso" > "GLF-OS-BETA-OMNISLASH_stable.iso.sha256sum"
		cat "GLF-OS-BETA-OMNISLASH_stable.iso.sha256sum"
	else
		echo "No ISO file found in result/iso"
	fi

#Ancienne façon de nommer
# SRC_DIR := result/iso
#	DEST_DIR := iso
#	GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
#	SRC_IMG=$$(ls -t $(SRC_DIR) | tail -1); \
#	DST_IMG="$${SRC_IMG/-x86_64-linux.iso/_$(GIT_BRANCH).iso}"; \
#	if [ -n "$$SRC_IMG" ]; then \
#		echo "Copying $(SRC_DIR)/$$SRC_IMG to $(DEST_DIR)/$$DST_IMG ..."; \
#		install -d $(DEST_DIR); \
#		install -m 644 "$(SRC_DIR)/$$SRC_IMG" $(DEST_DIR)/$$DST_IMG && \
#		cd $(DEST_DIR) && \
#		sha256sum "$$DST_IMG" > "$$DST_IMG.sha256sum"; \
#		cat "$$DST_IMG.sha256sum"; \


# Check, fix and format nix code
fix:
	#!/usr/bin/env bash
	find . -type f -name "*.nix" \
		! -path ./modules/default/debug.nix \
		! -path ./iso-cfg/customConfig/default.nix \
		-exec deadnix -eq {} \;
	find . -type f -name "*.nix" -exec nixfmt -s {} \;
	statix check .

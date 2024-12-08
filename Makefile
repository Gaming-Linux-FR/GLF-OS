# make without argument will perform a iso & install
all: iso install

# Test the configuration only
test:
	nixos-rebuild dry-build -I nixos-config=nix-cfg/configuration.nix

# Build new iso
iso:
	nix --extra-experimental-features "nix-command flakes" build .#iso

# Update flake.lock
update:
	nix --extra-experimental-features "nix-command flakes" flake update

# Clean local build
clean:
	@if [ -L "result" ]; then rm result; fi
	nix-collect-garbage
	@if [ -d "iso" ]; then rm -r iso; fi

# Copy image and compute sha256sum
SRC_DIR = result/iso
DEST_DIR = iso
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
install:
	@SRC_IMG=$$(ls -t $(SRC_DIR) | tail -1); \
	DST_IMG="$${SRC_IMG/-x86_64-linux.iso/_$(GIT_BRANCH).iso}"; \
	if [ -n "$$SRC_IMG" ]; then \
		echo "Copying $(SRC_DIR)/$$SRC_IMG to $(DEST_DIR)/$$DST_IMG ..."; \
		install -d $(DEST_DIR); \
		install -m 644 "$(SRC_DIR)/$$SRC_IMG" $(DEST_DIR)/$$DST_IMG && \
		cd $(DEST_DIR) && \
		sha256sum "$$DST_IMG" > "$$DST_IMG.sha256sum"; \
		cat "$$DST_IMG.sha256sum"; \
	fi

.PHONY: all test clean iso update install
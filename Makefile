# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
NIXNAME ?= vm-intel

# We need to do some OS switching below.
UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	nix --experimental-features 'nix-command flakes' build ".#darwinConfigurations.flemzords-MBP.system" --impure
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#flemzords-MBP" --impure
	unlink ./result
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif
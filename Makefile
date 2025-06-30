# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
NIXNAME ?= flemzord-MBP

# We need to do some OS switching below.
UNAME := $(shell uname)

DIR_TO_CHECK_FOR = '/opt/homebrew/Library/Taps'


switch:
ifeq ($(UNAME), Darwin)
ifeq ("$(wildcard $(DIR_TO_CHECK_FOR))", "")
	sudo /bin/chmod +a "flemzord allow list,add_file,search,delete,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,chown" /opt/homebrew/Library/Taps
else
	echo "Skipping chmod because directory not exists."
endif
	nix --experimental-features 'nix-command flakes' build ".#darwinConfigurations.${NIXNAME}.system" --impure
	sudo ./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}" --impure
	unlink ./result
	# nix-collect-garbage --delete-older-than 14d
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

update:
	nix flake update --commit-lock-file
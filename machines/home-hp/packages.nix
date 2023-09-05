{ pkgs }:

with pkgs;
let shared-packages = import ../../pkgs/shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  gnome.gnome-tweaks
  gnome.adwaita-icon-theme
]

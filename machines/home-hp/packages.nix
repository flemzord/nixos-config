{ pkgs }:

with pkgs;
let common-packages = import ../../pkgs/common/packages.nix { inherit pkgs; }; in
common-packages ++ [
  gnome.gnome-tweaks
  gnome.adwaita-icon-theme
]

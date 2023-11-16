{ pkgs }:

with pkgs;
let shared-packages = import ./../../pkgs/shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  vim
]

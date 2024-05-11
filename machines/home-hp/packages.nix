{ pkgs }:

with pkgs;
let shared-packages = import ./../../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  vim
  vscode
]

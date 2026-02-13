{ pkgs, lib, ... }:

let
  fullName = "Maxence Maireaux";
  email = "maxence@maireaux.fr";
in
{
  _module.args = {
    inherit fullName email;
  };

  imports = [
    ./../../modules/home-manager/programs/starship.nix
    ./../../modules/home-manager/programs/zsh.nix
    ./../../modules/home-manager/programs/git.nix
    ./../../modules/home-manager/programs/vim.nix
    ./../../modules/home-manager/programs/claude-code.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "flemzord";
    homeDirectory = "/home/flemzord";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "25.11";
    packages = pkgs.callPackage ./packages.nix { };
  };

  # Marked broken Oct 20, 2022 check later to remove this
  # https://github.com/nix-community/home-manager/issues/3344
  manual.manpages.enable = false;
}

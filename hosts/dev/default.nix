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

  home.file.".ssh/authorized_keys".text = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC33/UmOxIFBgPxxmr2qVqhN7wgdTLriKg4Em7MLi5KeIfWHs+Jqp7Fh6QDWwyOtRz8ARqtVlfZrO00xRAHx5UQkXmbd1iXeQgg7FPV+KuyAvAyfqciq0MJXFo5lIA9eO9TyFUKzC4dI/ayOubQDB8v5tCd+gYsW35eDrO5ueLi7ld2Q04lBO2mTNKoX0JUAd4+FYe9zkBXClh9ik0+F2IRBgG9HTVNqObUfXtpHp4iW0avXn7Syc4079rIkrwup7Swkxy1uo5nYeJSPHgnhDzjeCxzIal0UIDmPBHLAiuf8r2yWFb689jrmyfLYqN+o8QR2A5n+xQ5yxGmBDFKgkGN
  '';

  # Marked broken Oct 20, 2022 check later to remove this
  # https://github.com/nix-community/home-manager/issues/3344
  manual.manpages.enable = false;
}

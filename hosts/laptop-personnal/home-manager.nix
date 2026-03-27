{ pkgs, username, ... }:

let
  user = username;
  fullName = "Maxence Maireaux";
  email = "maxence@maireaux.fr";
in
{
  # Enable home-manager to manage the XDG standard
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} =
      { pkgs, lib, ... }:
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
          ./../../modules/home-manager/programs/codex.nix
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          stateVersion = "25.11";
          packages = pkgs.callPackage ./packages.nix { };
        };

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };
}

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

  home.activation.authorizedKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    cat > "$HOME/.ssh/authorized_keys" << 'SSH_KEYS'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHvSrBVrcw0wYewYB5RKkr2RTQ2aUyP74jFNZgR1YKb maxence@maireaux.fr
SSH_KEYS
    chmod 600 "$HOME/.ssh/authorized_keys"
  '';

  # Marked broken Oct 20, 2022 check later to remove this
  # https://github.com/nix-community/home-manager/issues/3344
  manual.manpages.enable = false;
}

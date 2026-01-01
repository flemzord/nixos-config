{ config, pkgs, ... }:

let
  user = "flemzord";
  fullName = "Maxence Maireaux";
  email = "maxence@maireaux.fr";
in
{
  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # We use Homebrew to install impure software only (Mac Apps)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brewPrefix = "/opt/homebrew/bin";
    taps = [
      "homebrew/cask"
      "homebrew/core"
      "formancehq/tap"
      "koyeb/tap"
      "loft-sh/tap"
      "earthly/earthly"
      "speakeasy-api/homebrew-tap"
      "temporalio/homebrew-tap"
      "charmbracelet/tap"
    ];
    casks = pkgs.callPackage ./casks.nix { };
    brews = [
      "formancehq/tap/fctl"
      "koyeb/tap/koyeb"
      "loft-sh/tap/vcluster"
      "earthly/earthly/earthly"
      "speakeasy-api/homebrew-tap/speakeasy"
      "temporalio/homebrew-tap/tcld"
      "temporal"
      "helmfile"
      #"ansible"
      "rbenv"
      "tmux"
      "charmbracelet/tap/crush"
      "argocd"
      "jiratui"
      "cocoapods"
      "trufflehog"
      "yamllint"
      "specify"
      "opencode"
    ];
  };

  # Enable home-manager to manage the XDG standard
  home-manager = {
    useGlobalPkgs = true;
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
          #./../../modules/home-manager/programs/aerospace.nix
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

{ pkgs, ... }:

{
  # Home-manager integration for dev environment
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.flemzord = { ... }: {
      _module.args = {
        fullName = "Maxence Maireaux";
        email = "maxence@maireaux.fr";
      };

      imports = [
        ../../home-manager/programs/starship.nix
        ../../home-manager/programs/zsh.nix
        ../../home-manager/programs/git.nix
        ../../home-manager/programs/vim.nix
        ../../home-manager/programs/claude-code.nix
        ../../home-manager/programs/codex.nix
      ];

      programs.home-manager.enable = true;

      home = {
        enableNixpkgsReleaseCheck = false;
        stateVersion = "25.11";
      };

      manual.manpages.enable = false;
    };
  };

  # Dev packages (system-wide)
  environment.systemPackages = (pkgs.callPackage ../common/dev-packages.nix { }) ++ (with pkgs; [
    (writeShellScriptBin "vercel" ''
      exec ${nodejs_22}/bin/npx --yes vercel "$@"
    '')
    packer
    hcloud
    php84Packages.composer
    xz
    (pkgs.php84.buildEnv {
      extensions = { enabled, all }: enabled ++ (with all; [
        xdebug
        pcov
      ]);
      extraConfig = ''
        xdebug.mode=debug,coverage
        xdebug.client_host=127.0.0.1
        xdebug.client_port="9003"
        memory_limit = -1
      '';
    })
  ]);
}

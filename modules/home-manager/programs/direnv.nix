{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    package = pkgs.direnv.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
      checkPhase = "true";
      installCheckPhase = "true";
    });
  };
}

{ pkgs, ... }:

let
  inherit (pkgs) plannotator;

  plannotatorHook = {
    type = "command";
    command = "/Users/flemzord/.local/bin/plannotator";
    timeout = 345600;
  };

  vibeIslandHook = {
    type = "command";
    command = "'/Users/flemzord/.vibe-island/bin/vibe-island-bridge' --source codex";
    timeout = 5;
  };
in
{
  home.file.".codex/hooks.json" = {
    force = true;
    source = (pkgs.formats.json { }).generate "codex-hooks" {
      hooks = {
        PermissionRequest = [
          {
            hooks = [ (vibeIslandHook // { timeout = 7200; }) ];
          }
        ];
        SessionStart = [
          {
            hooks = [ vibeIslandHook ];
          }
        ];
        Stop = [
          {
            hooks = [
              plannotatorHook
              vibeIslandHook
            ];
          }
        ];
        UserPromptSubmit = [
          {
            hooks = [ vibeIslandHook ];
          }
        ];
      };
    };
  };

  programs.codex = {
    enable = true;
    package = pkgs.codex; # From codex-cli-nix overlay
    skills = {
      plannotator-annotate = plannotator.skills + "/plannotator-annotate";
      plannotator-last = plannotator.skills + "/plannotator-last";
      plannotator-review = plannotator.skills + "/plannotator-review";
    };
  };

  home.packages = [
    plannotator
  ];
}

{ pkgs, ... }:

let
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
            hooks = [ vibeIslandHook ];
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
  };
}

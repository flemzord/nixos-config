{ pkgs, ... }:

let
  inherit (pkgs) plannotator;

  plannotatorHook = {
    type = "command";
    command = toString (pkgs.writeShellScript "codex-plannotator-stop-hook" ''
      set +e

      output="$("/Users/flemzord/.local/bin/plannotator" 2>&1)"
      status="$?"

      if [ -n "$output" ]; then
        printf '%s\n' "$output"
      fi

      if [ "$status" -eq 1 ] && [ "$output" = "No plan content in hook event" ]; then
        exit 0
      fi

      exit "$status"
    '');
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

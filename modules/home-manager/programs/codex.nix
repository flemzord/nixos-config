{ pkgs, ... }:

{
  programs.codex = {
    enable = true;
    package = pkgs.codex; # From codex-cli-nix overlay

    settings = {
      model = "gpt-5.5";
      model_reasoning_effort = "high";
      personality = "pragmatic";
      approval_mode = "full-auto";
      model_context_window = 1000000;
      model_auto_compact_token_limit = 9000000;

      projects = {
        "/Users/flemzord/Project" = {
          trust_level = "trusted";
        };
        tui = {
          notification_condition = "always";
        };
      };

      suppress_unstable_features_warning = true;

      features = {
        ghost_commit = false;
        unified_exec = true;
        apply_patch_freeform = true;
        skills = true;
        shell_snapshot = true;
        multi_agent = true;
      };
    };
  };
}

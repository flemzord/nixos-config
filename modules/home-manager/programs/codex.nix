{ pkgs, config, ... }:

{
  programs.codex = {
    enable = true;
    package = pkgs.codex; # From codex-cli-nix overlay

    settings = {
      model = "gpt-5.3-codex";
      model_reasoning_effort = "high";
      personality = "pragmatic";

      projects = {
        "/Users/flemzord/Project" = {
          trust_level = "trusted";
        };
      };

      features = {
        ghost_commit = false;
        unified_exec = true;
        apply_patch_freeform = true;
        web_search = "live";
        skills = true;
        shell_snapshot = true;
      };
    };
  };
}

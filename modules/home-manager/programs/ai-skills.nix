_:

# Single source of truth for skills shared across AI coding agents.
#
# Each skill lives once under ./skills/<name>/SKILL.md and is wired into both
# Claude Code and Codex from the same attribute set, so there is no content or
# wiring duplication. Adding a skill = drop a folder in ./skills and add one
# line below; it then shows up in both agents.
#
# Targets created as symlinks:
#   - Claude Code: ~/.claude/skills/<name>
#   - Codex:       ~/.agents/skills/<name>  (Codex >= 0.94, else ~/.codex/skills)
# Unmanaged skills installed by other tooling coexist untouched.

let
  sharedSkills = {
    grill-me = ./skills/grill-me;
    review-pr = ./skills/review-pr;
  };
in
{
  programs.claude-code.skills = sharedSkills;
  programs.codex.skills = sharedSkills;
}

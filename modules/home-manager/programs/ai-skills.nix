{ config, lib, ... }:

# Single source of truth for skills shared across AI coding agents.
#
# Each managed skill lives once under ./skills/<name>/SKILL.md and is exposed
# through ~/.agents/skills. Agent-specific skill directories are compatibility
# symlinks to ~/.agents/skills so unmanaged skills installed by other tooling
# coexist in the same canonical location.
#
# Targets created as symlinks:
#   - ~/.agents/skills/<name> -> managed source
#   - ~/.claude/skills        -> ~/.agents/skills
#   - ~/.codex/skills         -> ~/.agents/skills

let
  canonicalSkillsDir = "${config.home.homeDirectory}/.agents/skills";

  sharedSkills = {
    autoreview = ./skills/autoreview;
    grill-me = ./skills/grill-me;
    review-pr = ./skills/review-pr;
  };

  legacySkillDirs = [
    ".claude/skills"
    ".codex/skills"
  ];

  skillsDirectoryRule = ''
    # Skills Directory

    All user-managed AI agent skills must live in `~/.agents/skills`.

    Do not add or manage skills under agent-specific directories such as
    `~/.claude/skills` or `~/.codex/skills`; those paths are compatibility
    symlinks to `~/.agents/skills`.
  '';

  mkCanonicalSkillEntry = name: source:
    lib.nameValuePair ".agents/skills/${name}" {
      force = true;
      inherit source;
    };

  mkLegacySkillDir = target:
    lib.nameValuePair target {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink canonicalSkillsDir;
    };
in
{
  programs.claude-code.rules.skills-directory = skillsDirectoryRule;
  programs.codex.rules.skills-directory = skillsDirectoryRule;

  home = {
    activation = {
      migrateAiSkillsToAgents =
        lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
          canonical=${lib.escapeShellArg canonicalSkillsDir}
          run mkdir -p "$canonical"

          for legacy in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
            if [ ! -d "$legacy" ] || [ -L "$legacy" ]; then
              continue
            fi

            conflict=0
            for skill in "$legacy"/* "$legacy"/.[!.]* "$legacy"/..?*; do
              if [ ! -e "$skill" ] && [ ! -L "$skill" ]; then
                continue
              fi

              name="$(basename "$skill")"
              target="$canonical/$name"

              if [ -e "$target" ] || [ -L "$target" ]; then
                if diff -qr "$skill" "$target" >/dev/null 2>&1; then
                  run rm -rf "$skill"
                else
                  echo "Refusing to replace existing skill '$target' with '$skill'." >&2
                  conflict=1
                fi
              else
                run mv "$skill" "$target"
              fi
            done

            if [ "$conflict" -eq 0 ]; then
              run rmdir "$legacy" 2>/dev/null || true
            fi
          done
        '';

      removeManagedAiSkillBackups =
        lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          canonical=${lib.escapeShellArg canonicalSkillsDir}

          for skill in ${lib.escapeShellArgs (lib.attrNames sharedSkills)}; do
            for suffix in hm-backup backup; do
              backup="$canonical/$skill.$suffix"
              if [ -e "$backup" ] || [ -L "$backup" ]; then
                run rm -rf "$backup"
              fi
            done
          done
        '';
    };

    file =
      lib.mapAttrs' mkCanonicalSkillEntry sharedSkills
      // lib.listToAttrs (map mkLegacySkillDir legacySkillDirs);
  };
}

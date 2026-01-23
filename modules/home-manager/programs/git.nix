{ fullName, email, ... }:

{
  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
      ".idea"
      "*.DS_Store"
      "*.LSOverride"
      "Thumbs.db"
      ".bundle"
      ".fleet"
      ".direnv"
      ".env"
      "TODOS.md"
      "todos/"
      "CLAUDE.md"
      ".claude/"
      "tasks/"
      ".ralph-tui/"
      ".beads/"
      "ralph/"
    ];
    lfs = {
      enable = true;
    };
    settings = {
      user = {
        name = fullName;
        email = email;
        signingkey = "~/.ssh/github.pub";
      };
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
      pull.rebase = true;
      rebase.autoStash = true;
      push.autoSetupRemote = true;
    };
  };
}

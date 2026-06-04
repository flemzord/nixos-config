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
      ".omc/"
      ".claude/worktrees"
      ".gsd/"
    ];
    lfs = {
      enable = true;
    };
    includes = [
      {
        condition = "gitdir:~/Developer/Formance/";
        contents.user.email = "maxence@formance.com";
      }
    ];
    settings = {
      user = {
        name = fullName;
        inherit email;
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

{ name, email, ... }:

{
  programs.git = {
    enable = true;
    userName = name;
    userEmail = email;
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
      ".crush/"
    ];
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/github.pub";
      pull.rebase = true;
      rebase.autoStash = true;
      push.autoSetupRemote = true;
    };
  };
}

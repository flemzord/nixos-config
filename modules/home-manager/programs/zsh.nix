{ lib, ... }:

{
  programs.zsh = {
    enable = true;
    autocd = false;
    enableCompletion = true;
    history = {
      append = true;
      expireDuplicatesFirst = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "z"
      ];
    };
    cdpath = [ "~/.local/share/src" ];
    dirHashes = {
      code = "$HOME/.local/share/src";
      nixos-config = "$HOME/.local/share/src/nixos-config";
    };
    plugins = [ ];
    initContent = lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export EDITOR=vim

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"
      export HISTFILE=$HOME/.local/share/zsh/history
      export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:$PATH
      source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"

      export PATH="$HOME/.krew/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.cache/npm/bin:$PATH"
      eval "$(direnv hook zsh)"
      eval "$(atuin init zsh)"

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'

      alias dc='docker compose'
      alias k='kubectl'
      alias kx='kubectx'

      eval $(ssh-agent)
      ssh-add ~/.ssh/github

      export ANDROID_HOME=$HOME/Library/Android/sdk
      export PATH=$PATH:$ANDROID_HOME/emulator
      export PATH=$PATH:$ANDROID_HOME/platform-tools
      alias codex='npx @openai/codex@latest --yolo --search'
      alias laravel='/Users/flemzord/.config/composer/vendor/bin/laravel'
      export LIBRARY_PATH="$LIBRARY_PATH:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
      export TENV_AUTO_INSTALL=true
      export ENABLE_BACKGROUND_TASKS=1
      export CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1
      # Cursor Agent
      export PATH="$HOME/.local/bin:$PATH"
      # Rbenv
      eval "$(rbenv init - --no-rehash bash)"
      alias cc='claude --dangerously-skip-permissions'
    '';
  };
}

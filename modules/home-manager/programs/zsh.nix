{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
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
    initContent = lib.mkMerge [
      (lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export EDITOR=vim

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"
      export HISTFILE=$HOME/.local/share/zsh/history
      ${lib.optionalString isDarwin ''
      export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:$PATH
      source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
      ''}
      ${lib.optionalString (!isDarwin) ''
      export PATH="$HOME/bin:$HOME/go/bin:$PATH"
      ''}

      export PATH="$HOME/.krew/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.cache/npm/bin:$PATH"
      eval "$(direnv hook zsh)"

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'

      alias dc='docker compose'
      alias k='kubectl'
      alias kx='kubectx'

      if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
        eval $(ssh-agent) > /dev/null
        ssh-add ~/.ssh/github 2>/dev/null
      fi

      ${lib.optionalString isDarwin ''
      export ANDROID_HOME=$HOME/Library/Android/sdk
      export PATH=$PATH:$ANDROID_HOME/emulator
      export PATH=$PATH:$ANDROID_HOME/platform-tools
      alias laravel='/Users/flemzord/.config/composer/vendor/bin/laravel'
      ''}
      export TENV_AUTO_INSTALL=true
      export ENABLE_BACKGROUND_TASKS=1

      # Signoz OTEL headers (from agenix secret)
      if [[ -f "$HOME/.config/secrets/signoz-token" ]]; then
        export OTEL_EXPORTER_OTLP_HEADERS="$(cat "$HOME/.config/secrets/signoz-token")"
      fi
      export CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1
      # Cursor Agent
      export PATH="$HOME/.local/bin:$PATH"
      ${lib.optionalString isDarwin ''
      # Rbenv
      eval "$(rbenv init - --no-rehash bash)"
      ''}
      alias cc='claude --dangerously-skip-permissions'
      alias co='codex --full-auto'
      
      export CLAUDE_CODE_USE_BEDROCK=1
      export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
      
    '')
      (lib.mkAfter ''
        # Atuin must be initialized after oh-my-zsh to override Ctrl+R binding
        eval "$(atuin init zsh --disable-up-arrow)"
      '')
    ];
  };
}

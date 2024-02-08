{ config, pkgs, lib, home-manager, ... }:

let
  user = "flemzord";
  name = "Maxence Maireaux";
  email = "maxence@maireaux.fr";
in
{
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # We use Homebrew to install impure software only (Mac Apps)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brewPrefix = "/opt/homebrew/bin";
    casks = pkgs.callPackage ./casks.nix { };
    brews = [
      "formancehq/tap/fctl"
      "loft-sh/tap/vcluster"
      "earthly/earthly/earthly"
      "krew"
      # "renovate"
      # "protobuf"
      # "protoc-gen-go"
      # "protoc-gen-go-grpc"
      "awscli"
      "allure"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Bear" = 1091189122;
      "Infuse" = 1136220934;
      "Screegle" = 1591051659;
      "Tailscale" = 1475387142;
    };
  };

  # Enable home-manager to manage the XDG standard
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }: {
      home.enableNixpkgsReleaseCheck = false;
      home.stateVersion = "21.11";

      home.packages = pkgs.callPackage ./packages.nix { };
      programs = {
        starship = {
          enable = true;
          # Configuration written to ~/.config/starship.toml
          settings = {
            # add_newline = false;

            # character = {
            #   success_symbol = "[➜](bold green)";
            #   error_symbol = "[➜](bold red)";
            # };

            # package.disabled = true;
          };
        };

        zsh = {
          enable = true;
          autocd = false;
          cdpath = [ "~/.local/share/src" ];
          dirHashes = {
            code = "$HOME/.local/share/src";
            nixos-config = "$HOME/.local/share/src/nixos-config";
          };
          plugins = [

          ];
          initExtraFirst = ''
            if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
              . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
              . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
            fi

            # Remove history data we don't want to see
            export HISTIGNORE="pwd:ls:cd"
            export HISTFILE=$HOME/.local/share/zsh/history
            export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:$PATH
            source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"

            export PATH="~/.krew/bin:$PATH"
            export PATH="~/.local/bin:$PATH"
            eval "$(direnv hook zsh)"
          
            # Use difftastic, syntax-aware diffing
            alias diff=difft

            # Always color ls and group directories
            alias ls='ls --color=auto'

            alias dc='docker compose'
            alias k='kubectl'
            alias kx='kubectx'

            eval $(ssh-agent)
            ssh-add ~/.ssh/github
          '';
        };
        git = {
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
            ".envrc"
          ];
          userName = name;
          userEmail = email;
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
        vim = {
          enable = true;
          plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes vim-startify vim-tmux-navigator ];
          settings = { ignorecase = true; };
          extraConfig = ''
            "" General
            set number
            set history=1000
            set nocompatible
            set modelines=0
            set encoding=utf-8
            set scrolloff=3
            set showmode
            set showcmd
            set hidden
            set wildmenu
            set wildmode=list:longest
            set cursorline
            set ttyfast
            set nowrap
            set ruler
            set backspace=indent,eol,start
            set laststatus=2
            set clipboard=autoselect

            " Dir stuff
            set nobackup
            set nowritebackup
            set noswapfile
            set backupdir=~/.config/vim/backups
            set directory=~/.config/vim/swap

            " Relative line numbers for easy movement
            set relativenumber
            set rnu

            "" Whitespace rules
            set tabstop=8
            set shiftwidth=2
            set softtabstop=2
            set expandtab

            "" Searching
            set incsearch
            set gdefault

            "" Statusbar
            set nocompatible " Disable vi-compatibility
            set laststatus=2 " Always show the statusline
            let g:airline_theme='bubblegum'
            let g:airline_powerline_fonts = 1

            "" Local keys and such
            let mapleader=","
            let maplocalleader=" "

            "" Change cursor on mode
            :autocmd InsertEnter * set cul
            :autocmd InsertLeave * set nocul

            "" File-type highlighting and configuration
            syntax on
            filetype on
            filetype plugin on
            filetype indent on

            "" Paste from clipboard
            nnoremap <Leader>, "+gP

            "" Copy from clipboard
            xnoremap <Leader>. "+y

            "" Move cursor by display lines when wrapping
            nnoremap j gj
            nnoremap k gk

            "" Map leader-q to quit out of window
            nnoremap <leader>q :q<cr>

            "" Move around split
            nnoremap <C-h> <C-w>h
            nnoremap <C-j> <C-w>j
            nnoremap <C-k> <C-w>k
            nnoremap <C-l> <C-w>l

            "" Easier to yank entire line
            nnoremap Y y$

            "" Move buffers
            nnoremap <tab> :bnext<cr>
            nnoremap <S-tab> :bprev<cr>

            "" Like a boss, sudo AFTER opening the file to write
            cmap w!! w !sudo tee % >/dev/null

            let g:startify_lists = [
              \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
              \ { 'type': 'sessions',  'header': ['   Sessions']       },
              \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      }
              \ ]

            let g:startify_bookmarks = [
              \ '~/.local/share/src',
              \ ]

            let g:airline_theme='bubblegum'
            let g:airline_powerline_fonts = 1
          '';
        };
      };
      # programs = { } // import ./home-manager { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/Applications/Arc.app/"; }
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Discord.app/"; }
    { path = "/Applications/Beeper.app/"; }
    { path = "/Applications/WhatsApp.app/"; }
    { path = "/Applications/Warp.app/"; }
    { path = "/System/Applications/Home.app/"; }
    { path = "/Applications/Notion Calendar.app/"; }
    { path = "/Applications/Superhuman.app/"; }
    {
      path = "/Applications";
      section = "others";
    }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort datemodified --view grid --display stack";
    }
  ];
}

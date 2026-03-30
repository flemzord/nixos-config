{ pkgs, lib, ... }:

{
  # Home-manager integration for dev environment
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.flemzord = { pkgs, lib, ... }: {
      _module.args = {
        fullName = "Maxence Maireaux";
        email = "maxence@maireaux.fr";
      };

      imports = [
        ../../home-manager/programs/starship.nix
        ../../home-manager/programs/zsh.nix
        ../../home-manager/programs/git.nix
        ../../home-manager/programs/vim.nix
        ../../home-manager/programs/claude-code.nix
        ../../home-manager/programs/codex.nix
      ];

      programs.home-manager.enable = true;

      home = {
        enableNixpkgsReleaseCheck = false;
        stateVersion = "25.11";
      };

      manual.manpages.enable = false;
    };
  };

  # Dev packages (system-wide)
  environment.systemPackages = with pkgs; [
    # Essential utilities
    ragenix
    nixpkgs-fmt
    nixd
    statix
    difftastic
    coreutils
    flyctl
    atuin
    fd
    fzf
    font-awesome
    gcc
    gh
    git-filter-repo
    gnupg
    hack-font
    jetbrains-mono
    killall
    libfido2
    fastfetch
    ripgrep
    sqlite
    sshpass
    zsh-powerlevel10k
    ffmpeg
    curl
    wget
    turso-cli
    newman
    mosh
    htop

    # Cloud & K8s tools
    krew
    k3d
    awscli2
    pipx
    git-subrepo
    go-task
    httpie
    k6
    kubectx
    kubernetes-helm
    helm-docs
    supabase-cli
    packer
    hcloud
    tenv
    direnv
    yq
    jq
    k9s
    ko
    watch
    tree
    postgresql_16
    natscli
    kind
    process-compose
    fluxcd
    ncdu
    pg_activity
    ipcalc

    # NodeJS
    nodejs_22
    pnpm
    yarn
    bun

    # Rust
    rustc
    cargo
    cmake
    gnumake

    # PHP
    php84Packages.composer
    xz
    (pkgs.php84.buildEnv {
      extensions = { enabled, all }: enabled ++ (with all; [
        xdebug
        pcov
      ]);
      extraConfig = ''
        xdebug.mode=debug,coverage
        xdebug.client_host=127.0.0.1
        xdebug.client_port="9003"
        memory_limit = -1
      '';
    })

    # Python
    uv
    python313
    python313Packages.click

    # AI tools
    claude-code
    gemini-cli
  ];
}

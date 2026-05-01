{ config, pkgs, ... }:

let
  ghTokenKey = "GITHUB_" + "TOKEN";
in
{
  systemd.services.hermes-github-auth = {
    description = "Configure persistent GitHub CLI auth for Hermes";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "hermes";
      Group = "hermes";
      Environment = "HOME=/var/lib/hermes";
      UMask = "0077";
    };

    path = [
      pkgs.git
    ];

    script = ''
      set -euo pipefail

      ${pkgs.coreutils}/bin/install -d -m 700 /var/lib/hermes/.config/gh

      token_key='${ghTokenKey}'
      token="$(${pkgs.gnugrep}/bin/grep "^''${token_key}=" ${config.age.secrets.hermes-env.path} | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.coreutils}/bin/cut -d= -f2-)"

      if [ -z "$token" ]; then
        echo "GitHub token not found in ${config.age.secrets.hermes-env.path}" >&2
        exit 1
      fi

      printf '%s' "$token" | ${pkgs.gh}/bin/gh auth login --hostname github.com --git-protocol https --with-token
      ${pkgs.gh}/bin/gh auth setup-git
    '';
  };
}

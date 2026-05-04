{ config
, lib
, pkgs
, ...
}:

let
  sideProjectProfiles = {
    product = pkgs.writeText "hermes-profile-product-SOUL.md" ''
      # Product Profile

      You are the Product Manager for Maxence's side-project studio.

      Role:
      - Turn rough ideas into clear product bets.
      - Define ICP, problem, promise, scope, MVP, roadmap, and acceptance criteria.
      - Challenge assumptions before implementation.
      - Prefer small validated increments over large speculative builds.
      - Produce crisp specs and Kanban-ready tasks.

      Operating principles:
      - Write in French unless the task asks otherwise.
      - Be concrete: user stories, edge cases, trade-offs, and definition of done.
      - Escalate only for decisions that materially affect product direction.
      - Do not implement code unless explicitly assigned; hand off to `dev`.
    '';
    researcher = pkgs.writeText "hermes-profile-researcher-SOUL.md" ''
      # Researcher Profile

      You are the research and market-intelligence agent for Maxence's side-project studio.

      Role:
      - Research markets, competitors, regulations, technical docs, APIs, and pricing.
      - Validate demand and identify risks before build.
      - Summarize findings with sources and confidence levels.
      - Convert research into product, growth, or engineering implications.

      Operating principles:
      - Write in French unless the task asks otherwise.
      - Always cite source URLs for current/external claims.
      - Separate facts, assumptions, and recommendations.
      - Prefer concise, decision-oriented briefs over long dumps.
      - Do not implement code unless explicitly assigned; hand off to `product`, `dev`, or `growth`.
    '';
    dev = pkgs.writeText "hermes-profile-dev-SOUL.md" ''
      # Dev Profile

      You are the implementation engineer for Maxence's side-project studio.

      Role:
      - Build features, fix bugs, write tests, maintain CI/build quality, and prepare PR-ready commits.
      - Use TDD where feasible: write failing tests first, then implement.
      - Delegate focused coding subtasks to Codex when useful, then verify the result yourself.
      - Keep changes scoped and commit cleanly.

      Operating principles:
      - Work on the assigned branch/workspace only.
      - Never merge to main unless explicitly instructed.
      - Preserve unrelated local changes and untracked files.
      - Run targeted tests/lint/build checks and report exact results.
      - Never expose secrets; use [REDACTED].
      - Escalate only when blocked by missing access, ambiguous product decisions, or unsafe operations.
    '';
    reviewer = pkgs.writeText "hermes-profile-reviewer-SOUL.md" ''
      # Reviewer Profile

      You are the staff-engineer reviewer for Maxence's side-project studio.

      Role:
      - Review code, architecture, security, tests, UX consistency, and release readiness.
      - Find real issues, not stylistic noise.
      - Check diffs against the stated product/spec acceptance criteria.
      - Recommend precise fixes or approval with residual risks.

      Operating principles:
      - Write in French unless the task asks otherwise.
      - Prefer evidence: file paths, lines, test output, diff references.
      - Do not make broad implementation changes unless explicitly assigned.
      - Never merge to main unless explicitly instructed.
      - Never expose secrets; use [REDACTED].
    '';
    growth = pkgs.writeText "hermes-profile-growth-SOUL.md" ''
      # Growth Profile

      You are the growth, marketing, and launch agent for Maxence's side-project studio.

      Role:
      - Define positioning, messaging, landing-page copy, SEO angles, launch plans, and acquisition experiments.
      - Translate product capabilities into clear customer value.
      - Prepare assets for launches: website sections, social posts, email sequences, outreach, and analytics plans.

      Operating principles:
      - Write in French unless the task asks otherwise.
      - Be specific about audience, channel, promise, CTA, and success metrics.
      - Avoid generic SaaS fluff; prefer sharp, credible, testable messaging.
      - Coordinate with `product` for positioning and `designer` for visual direction.
    '';
    designer = pkgs.writeText "hermes-profile-designer-SOUL.md" ''
      # Designer Profile

      You are the product designer and visual-design agent for Maxence's side-project studio.

      Role:
      - Improve UI structure, visual hierarchy, design systems, landing pages, UX flows, and brand expression.
      - Produce design audits, wireframes, component recommendations, and implementation-ready UI specs.
      - Help `growth` turn positioning into high-converting landing pages.
      - Help `dev` keep interfaces coherent, accessible, responsive, and maintainable.

      Operating principles:
      - Write in French unless the task asks otherwise.
      - Ground feedback in actual product screens/components when possible.
      - Think in user journeys, hierarchy, contrast, spacing, rhythm, accessibility, and conversion.
      - Prefer implementable design guidance over vague taste statements.
      - Do not implement code unless explicitly assigned; hand off to `dev` or provide precise specs.
    '';
  };

  setupSideProjectProfiles = pkgs.writeShellScript "setup-hermes-side-project-profiles" ''
    set -euo pipefail

    export HOME=/var/lib/hermes
    export HERMES_HOME=/var/lib/hermes/.hermes
    export HERMES_MANAGED=true

    install -d -m 700 "$HERMES_HOME" "$HERMES_HOME/profiles"

      if [ ! -d "$HERMES_HOME/profiles/product" ]; then
        ${config.services.hermes-agent.package}/bin/hermes profile create product --clone --no-alias
      fi

      install -d -m 700 "$HERMES_HOME/profiles/product"
      install -m 600 ${sideProjectProfiles.product} "$HERMES_HOME/profiles/product/SOUL.md"

      if [ ! -d "$HERMES_HOME/profiles/researcher" ]; then
        ${config.services.hermes-agent.package}/bin/hermes profile create researcher --clone --no-alias
      fi

      install -d -m 700 "$HERMES_HOME/profiles/researcher"
      install -m 600 ${sideProjectProfiles.researcher} "$HERMES_HOME/profiles/researcher/SOUL.md"

      if [ ! -d "$HERMES_HOME/profiles/dev" ]; then
        ${config.services.hermes-agent.package}/bin/hermes profile create dev --clone --no-alias
      fi

      install -d -m 700 "$HERMES_HOME/profiles/dev"
      install -m 600 ${sideProjectProfiles.dev} "$HERMES_HOME/profiles/dev/SOUL.md"

      if [ ! -d "$HERMES_HOME/profiles/reviewer" ]; then
        ${config.services.hermes-agent.package}/bin/hermes profile create reviewer --clone --no-alias
      fi

      install -d -m 700 "$HERMES_HOME/profiles/reviewer"
      install -m 600 ${sideProjectProfiles.reviewer} "$HERMES_HOME/profiles/reviewer/SOUL.md"

      if [ ! -d "$HERMES_HOME/profiles/growth" ]; then
        ${config.services.hermes-agent.package}/bin/hermes profile create growth --clone --no-alias
      fi

      install -d -m 700 "$HERMES_HOME/profiles/growth"
      install -m 600 ${sideProjectProfiles.growth} "$HERMES_HOME/profiles/growth/SOUL.md"

      if [ ! -d "$HERMES_HOME/profiles/designer" ]; then
        ${config.services.hermes-agent.package}/bin/hermes profile create designer --clone --no-alias
      fi

      install -d -m 700 "$HERMES_HOME/profiles/designer"
      install -m 600 ${sideProjectProfiles.designer} "$HERMES_HOME/profiles/designer/SOUL.md"
  '';
in
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/profiles/nixos/dev.nix
    ./../../modules/services/hermes-github-auth.nix
    ./../../modules/services/hermes-kanban.nix
    ./../../modules/services/postgresql.nix
    ./../../modules/services/fail2ban.nix
  ];

  # Bootloader — UEFI on Hetzner Cloud ARM vServer
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "server-dev";

    # Use systemd-networkd; disable NetworkManager from the common profile
    networkmanager.enable = lib.mkForce false;
    firewall.enable = lib.mkForce true;
  };

  age.secrets.hermes-env = {
    file = ../../secrets/hermes-env.age;
    owner = "hermes";
    group = "hermes";
    mode = "0400";
  };

  age.secrets.openai-api-key = {
    file = ../../secrets/openai-api-key.age;
    owner = "root";
    group = "openai-api-key";
    mode = "0440";
  };

  users.groups.openai-api-key.members = [
    "hermes"
  ];

  services = {
    nixos-auto-update = {
      enable = true;
      hostname = "server-dev";
    };

    hermes-agent = {
      enable = true;
      settings = {
        model = {
          provider = "openai-codex";
          default = "gpt-5.5";
        };
        fallback_providers = [
          {
            provider = "custom";
            model = "gpt-5.5";
            base_url = "https://api.openai.com/v1";
            key_env = "OPENAI_API_KEY";
          }
        ];
        auxiliary.vision = {
          provider = "codex";
          model = "gpt-5.5";
          base_url = null;
          timeout = 120;
        };
      };
      environment = {
        CODEX_HOME = "${config.services.hermes-agent.stateDir}/.codex";
      };
      environmentFiles = [
        config.age.secrets.openai-api-key.path
        config.age.secrets.hermes-env.path
      ];
      extraPackages = [
        pkgs.codex
        pkgs.google-cloud-sdk
        pkgs.googleworkspace-cli
        pkgs.python3Packages.weasyprint
        pkgs.turso-cli
      ];
      addToSystemPackages = true;
      mcpServers.github = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-github"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "$" + "{GITHUB_" + "TOKEN}";
        };
      };
      mcpServers.deepwiki = {
        url = "https://mcp.deepwiki.com/mcp";
      };
    };
  };



  systemd.services.hermes-side-project-profiles = {
    description = "Ensure Hermes side-project studio profiles exist";
    after = [ "hermes-agent.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "hermes";
      Group = "hermes";
      Environment = [
        "HOME=/var/lib/hermes"
        "HERMES_HOME=/var/lib/hermes/.hermes"
        "HERMES_MANAGED=true"
      ];
      UMask = "0077";
    };

    path = [
      config.services.hermes-agent.package
      pkgs.coreutils
    ];

    script = ''
      ${setupSideProjectProfiles}
    '';
  };

  system.stateVersion = "25.11";
}

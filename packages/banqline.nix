{ fetchFromGitHub
, lib
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "banqline";
  version = "0.1.0-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "arkan";
    repo = "banqline";
    rev = "c294608a2f6a743d8044a900a8ba67035c07be1f";
    hash = "sha256-uqfko6RixAkUwh5UK5nUFNCWwtrcprCc7hZrHjAJVG8=";
  };

  cargoHash = "sha256-d+6Wq7BpNdIqV5ImyiVXwLZOWusOqEfaX2RRkessPzQ=";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  meta = {
    description = "Terminal-first personal banking CLI and TUI powered by Enable Banking";
    homepage = "https://github.com/arkan/banqline";
    license = lib.licenses.mit;
    mainProgram = "banqline";
    platforms = lib.platforms.unix;
  };
}

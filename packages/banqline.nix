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
    rev = "b4e293ec38b84e1fb17b1c4b3c83fd2fd2be1770";
    hash = "sha256-R13yyXHOwJTlDPDpoEyNLpWw+zXEubGIPi2oUZik6d0=";
  };

  cargoHash = "sha256-OthVN0yP8hg6S3yri3gdFllLEBOjqxR3oHruKD62kS0=";

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

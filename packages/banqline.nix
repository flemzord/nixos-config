{ fetchFromGitHub
, lib
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "banqline";
  version = "0.1.0-unstable-2026-05-24";

  src = fetchFromGitHub {
    owner = "arkan";
    repo = "banqline";
    rev = "d8eb7a8e9f059e9140df7e09cd76a758c3947c0d";
    hash = "sha256-jMzCoaiEnOaXjhLi/DSSpx49vy+p3oPtzihFBZfpPVQ=";
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

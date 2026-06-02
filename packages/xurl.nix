{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "xurl";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "xdevplatform";
    repo = "xurl";
    rev = "v${version}";
    hash = "sha256-sL1CIXM3tD9pL8hig+UhBAK7G+4JVOFevHdIyS3DhCU=";
  };

  vendorHash = "sha256-sYGm/Yrcu+i+EsjcJfZcCrp3tvWLxo8cte5YnC0fEbI=";

  postPatch = ''
    substituteInPlace api/client_test.go \
      --replace-fail '"xurl/dev"' '"xurl/${version}"'
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/xdevplatform/xurl/version.Version=${version}"
  ];

  meta = {
    description = "Auth-enabled curl-like CLI for the X API";
    homepage = "https://github.com/xdevplatform/xurl";
    license = lib.licenses.mit;
    mainProgram = "xurl";
  };
}

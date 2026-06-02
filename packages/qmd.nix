{ bun
, darwin
, fetchFromGitHub
, lib
, makeWrapper
, node-gyp
, nodejs
, python3
, sqlite
, stdenv
}:

let
  nodeModulesHashes = {
    x86_64-linux = "sha256-sVXoNWIcx1RYRtRWB4F2j7x8/cabFBKq+plFhPU7tBc=";
    aarch64-darwin = "sha256-xvmzyfJTw4l9eR6jB4OHolwaQFDWnHMjRj83VLJeaRE=";

    aarch64-linux = "sha256-+6Sa/IjLdoD9Xm42Bzp/4xdB3I4q+FT3wjSi0sGo9eY=";

    x86_64-darwin = "sha256-1Kz0pOO3DOcJCFOwbg61f9e00wEBMNiQnl9IsXkGjLk=";
  };

  nodeModulesHash = nodeModulesHashes.${stdenv.hostPlatform.system} or lib.fakeHash;
in
stdenv.mkDerivation rec {
  pname = "qmd";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "v${version}";
    hash = "sha256-bFk078qQ8Ha/1na+r5ka6yNPI/Pealh0Rk6hJxKBwNs=";
  };

  nativeBuildInputs = [
    bun
    makeWrapper
    node-gyp
    nodejs
    python3
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.cctools
  ];

  buildInputs = [
    sqlite
  ];

  nodeModules = stdenv.mkDerivation {
    pname = "qmd-node-modules";
    inherit src version;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)

      bunInstallFlags=(
        --backend copyfile
        --frozen-lockfile
        --ignore-scripts
        --no-progress
        --production
      )

      ${lib.optionalString (stdenv.hostPlatform.system == "aarch64-darwin") ''
        bunInstallFlags+=(--omit=peer)
      ''}

      bun install "''${bunInstallFlags[@]}"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = nodeModulesHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)

    cp -R $nodeModules/node_modules ./
    chmod -R u+w node_modules

    (cd node_modules/better-sqlite3 && node-gyp rebuild --release)

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qmd $out/bin

    cp -R node_modules $out/lib/qmd/
    cp -R src $out/lib/qmd/
    cp package.json $out/lib/qmd/

    makeWrapper ${bun}/bin/bun $out/bin/qmd \
      --add-flags "$out/lib/qmd/src/cli/qmd.ts" \
      --set DYLD_LIBRARY_PATH "${sqlite.out}/lib" \
      --set LD_LIBRARY_PATH "${sqlite.out}/lib"

    runHook postInstall
  '';

  meta = {
    description = "On-device search engine for markdown notes, meeting transcripts, and knowledge bases";
    homepage = "https://github.com/tobi/qmd";
    license = lib.licenses.mit;
    mainProgram = "qmd";
    platforms = lib.platforms.unix;
  };
}

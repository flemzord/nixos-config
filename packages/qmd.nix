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
    x86_64-linux = "sha256-D0ezO4vqq4iswcAMU2DCql9ZAQvh3me6N9aDB5roq4w=";
    aarch64-darwin = "sha256-qU+9KdR/nTocelyANS09I/4yaQ+7s1LvJNqB27IOK/c=";

    aarch64-linux = "sha256-4Pq5tIonuB2TQ1NmKF42oZVb5vEMtXwY2vf1msQ1/Bk=";

    # Populate this on first build if needed.
    x86_64-darwin = lib.fakeHash;
  };

  nodeModulesHash = nodeModulesHashes.${stdenv.hostPlatform.system} or lib.fakeHash;
in
stdenv.mkDerivation rec {
  pname = "qmd";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "v${version}";
    hash = "sha256-bqIVaNRTa8H5vrw3RwsD7QdtTa0xNvRuEVzlzE1hIBQ=";
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

      bun install \
        --backend copyfile \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production

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

{ buildNpmPackage
, fetchFromGitHub
, lib
, nodejs_22
, python3
}:

buildNpmPackage rec {
  pname = "gitnexus";
  version = "1.6.8";

  src = fetchFromGitHub {
    owner = "abhigyanpatwari";
    repo = "GitNexus";
    rev = "v${version}";
    hash = "sha256-2LvkIlQb4fk1DuI7sXjAm2xgNCQo/OX79A+Lw6xt6Js=";
  };

  sourceRoot = "${src.name}/gitnexus";

  npmDepsHash = "sha256-qTQTi3KYyPhZib4WWDE5S+tk8iY5rvtCQzBI2P4CA90=";
  npmDepsFetcherVersion = 2;
  nodejs = nodejs_22;

  nativeBuildInputs = [
    python3
  ];

  env = {
    GITNEXUS_SKIP_OPTIONAL_GRAMMARS = "1";
    SCARF_ANALYTICS = "false";
  };

  postPatch = ''
    substituteInPlace scripts/build.js \
      --replace-fail \
        "execSync(tscCmd, { cwd: SHARED_ROOT, stdio: 'inherit', timeout: BUILD_TIMEOUT_MS });" \
        "execSync(tscCmd + ' -p ../gitnexus-shared/tsconfig.json', { cwd: ROOT, stdio: 'inherit', timeout: BUILD_TIMEOUT_MS });" \
      --replace-fail \
        "if (fs.existsSync(path.join(WEB_ROOT, 'package.json'))) {" \
        "if (false && fs.existsSync(path.join(WEB_ROOT, 'package.json'))) {"
  '';

  preBuild = ''
    chmod -R u+w ../gitnexus-shared
  '';

  dontNpmPrune = true;

  postInstall = ''
    rm -f "$out/lib/node_modules/gitnexus/node_modules/gitnexus-shared"
  '';

  meta = {
    description = "Graph-powered code intelligence for AI agents";
    homepage = "https://github.com/abhigyanpatwari/GitNexus";
    license = {
      fullName = "PolyForm Noncommercial License 1.0.0";
      shortName = "polyform-noncommercial-1.0.0";
      url = "https://polyformproject.org/licenses/noncommercial/1.0.0/";
      free = false;
    };
    mainProgram = "gitnexus";
    platforms = lib.platforms.unix;
  };
}

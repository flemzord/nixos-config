{ buildNpmPackage
, fetchFromGitHub
, lib
, nodejs_22
, python3
}:

buildNpmPackage rec {
  pname = "gitnexus";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "abhigyanpatwari";
    repo = "GitNexus";
    rev = "v${version}";
    hash = "sha256-YpNxXei0A+rHlHlBlAzMt54rJFNSyTkC5sOJZjP7ArA=";
  };

  sourceRoot = "${src.name}/gitnexus";

  npmDepsHash = "sha256-O1VmviQ/jyqBY0rASdaAJaJuYyeAu6HPKR7iL5ihCA8=";
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
        "execSync('npx tsc', { cwd: SHARED_ROOT, stdio: 'inherit', timeout: 120_000 });" \
        "execSync('npx tsc -p ../gitnexus-shared/tsconfig.json', { cwd: ROOT, stdio: 'inherit', timeout: 120_000 });" \
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

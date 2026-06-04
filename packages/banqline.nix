{ fetchurl
, lib
, stdenvNoCC
}:

let
  version = "0.1.2";
  targetBySystem = {
    aarch64-darwin = "aarch64-apple-darwin";
    aarch64-linux = "aarch64-unknown-linux-gnu";
    x86_64-darwin = "x86_64-apple-darwin";
    x86_64-linux = "x86_64-unknown-linux-gnu";
  };
  hashBySystem = {
    aarch64-darwin = "sha256-nIMq3k0jO4E0TzO8kHgn6hnfLBJ6Cru+EYEHYBeLJ98=";
    aarch64-linux = "sha256-aNq3PTtfr9UjTJO+7ndIooW3QAwf/gv5JeihTvB7q9I=";
    x86_64-darwin = "sha256-02RmZDzmVI3NI5GU89NUzRCwQmprOCV4KJrsNpnQb20=";
    x86_64-linux = "sha256-0XTOmWceBGtQnnCtWqENByVV+FTXLu5wzz0iGFnizxw=";
  };

  system = stdenvNoCC.hostPlatform.system;
  target = targetBySystem.${system}
    or (throw "banqline: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "banqline";
  inherit version;

  src = fetchurl {
    url = "https://github.com/arkan/banqline/releases/download/v${version}/banqline-${version}-${target}.tar.gz";
    hash = hashBySystem.${system};
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 banqline "$out/bin/banqline"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/banqline" --help >/dev/null
    "$out/bin/banqline" version >/dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Terminal-first personal banking CLI and TUI powered by Enable Banking";
    homepage = "https://github.com/arkan/banqline";
    license = lib.licenses.mit;
    mainProgram = "banqline";
    platforms = builtins.attrNames targetBySystem;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

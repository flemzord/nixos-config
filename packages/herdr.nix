{ fetchurl
, lib
, stdenvNoCC
}:

let
  version = "0.5.9";

  assets = {
    aarch64-darwin = {
      name = "herdr-macos-aarch64";
      hash = "sha256-i3lvNxeGKq6B2q5bnWwfGSnXWKrOoLRDO79TAO0spqw=";
    };
    x86_64-darwin = {
      name = "herdr-macos-x86_64";
      hash = "sha256-AObDRtzEjBzr+zE8fxIKH2BCavikGGCDchDIL2ZXvLA=";
    };
    aarch64-linux = {
      name = "herdr-linux-aarch64";
      hash = "sha256-mjiUGkpU134MUQHRgScMqV8S5QReMVkvAPAHYwAjgQ0=";
    };
    x86_64-linux = {
      name = "herdr-linux-x86_64";
      hash = "sha256-E/7B0cqoL6OSVBbXNJdsk8eoTVqHEmrzGQkKOBed524=";
    };
  };

  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "herdr is not available for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "herdr";
  inherit version;

  src = fetchurl {
    url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/${asset.name}";
    inherit (asset) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/herdr

    runHook postInstall
  '';

  meta = {
    description = "Agent multiplexer that lives in your terminal";
    homepage = "https://herdr.dev";
    changelog = "https://github.com/ogulcancelik/herdr/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "herdr";
    platforms = builtins.attrNames assets;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

{ fetchurl
, lib
, stdenvNoCC
}:

let
  version = "0.6.6";

  assets = {
    aarch64-darwin = {
      name = "herdr-macos-aarch64";
      hash = "sha256-VDf4fKx02whbvFFhmAT7YQZvSfd8JX8zMzEDW75ebD8=";
    };
    x86_64-darwin = {
      name = "herdr-macos-x86_64";
      hash = "sha256-9QeO6Lr5jyt9iRhgZerKunm5E59mEvxVQJJ8gZq7Z8U=";
    };
    aarch64-linux = {
      name = "herdr-linux-aarch64";
      hash = "sha256-aYI3XQGRAW4myM4XNC6lJHiPbDrrTzlJ0AFfUeM9FtI=";
    };
    x86_64-linux = {
      name = "herdr-linux-x86_64";
      hash = "sha256-DQwKOUaUNO+zYw1yWfn5FGO61yekwQ7RxAwG0wvA6qw=";
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

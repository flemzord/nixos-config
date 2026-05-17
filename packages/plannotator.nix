{ fetchFromGitHub
, fetchurl
, lib
, stdenv
}:

let
  version = "0.19.17";
  tag = "v${version}";

  assets = {
    aarch64-darwin = {
      name = "plannotator-darwin-arm64";
      hash = "sha256-O42vppwqf+flBIx94Lhiojl+4CKDsnU8yhPWSUWGcqo=";
    };
    x86_64-darwin = {
      name = "plannotator-darwin-x64";
      hash = "sha256-dpYsaKC788GGUSxoDNuNwxqA1Kf5ha817p3yIvnh/Nw=";
    };
    aarch64-linux = {
      name = "plannotator-linux-arm64";
      hash = "sha256-1zTmsxDUiJsaEIzOiDQK/P4miY51o0AfECDSzbpna3I=";
    };
    x86_64-linux = {
      name = "plannotator-linux-x64";
      hash = "sha256-/y2z9a3UZ+oZ9cqE5KY3Ezo92f28bSdgjKaakiGG/tA=";
    };
  };

  asset =
    assets.${stdenv.hostPlatform.system}
      or (throw "plannotator is not supported on ${stdenv.hostPlatform.system}");

  source = fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    rev = tag;
    hash = "sha256-iLFn6pb5Lkd3wWxpAw/SWg64tLQ4KpPjR5/KaSMehUA=";
  };
in
stdenv.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/${tag}/${asset.name}";
    inherit (asset) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/plannotator"
    runHook postInstall
  '';

  passthru = {
    skills = source + "/apps/skills";
  };

  meta = {
    description = "Interactive plan and code review UI for AI coding agents";
    homepage = "https://github.com/backnotprop/plannotator";
    license = with lib.licenses; [ asl20 mit ];
    maintainers = [ ];
    mainProgram = "plannotator";
    platforms = builtins.attrNames assets;
  };
}

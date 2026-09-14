{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "4.19.1";
in
stdenvNoCC.mkDerivation {
  pname = "chirpstack";
  inherit version;

  src = fetchurl {
    url = "https://artifacts.chirpstack.io/downloads/chirpstack/chirpstack_${version}_postgres_linux_arm64.tar.gz";
    hash = lib.fakeHash;
  };

  unpackPhase = ''
    runHook preUnpack

    mkdir source
    tar -xzf "$src" -C source

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 source/chirpstack "$out/bin/chirpstack"

    runHook postInstall
  '';

  meta = {
    description = "ChirpStack open-source LoRaWAN Network Server";
    homepage = "https://www.chirpstack.io/";
    license = lib.licenses.mit;
    platforms = [ "aarch64-linux" ];
    mainProgram = "chirpstack";
  };
}

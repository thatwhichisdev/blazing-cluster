{ lib, stdenvNoCC, fetchurl, autoPatchelfHook, sqlite, openssl, zlib
, gcc-unwrapped, systemd }:

let
  version = "4.15.0";
  url =
    "https://artifacts.chirpstack.io/downloads/chirpstack/chirpstack_${version}_sqlite_linux_arm64.tar.gz";
in stdenvNoCC.mkDerivation {
  pname = "chirpstack-network-server";
  inherit version;

  src = fetchurl {
    inherit url;

    sha256 = "sha256-WKMIPCIhcIO/woe6SOE+clnvH8nwMt14RPO/vf0a45s=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ sqlite openssl zlib gcc-unwrapped.lib systemd ];

  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    tar -xzf "$src" -C source
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"

    # The tarball should contain chirpstack-sqlite.
    if [ -f source/chirpstack-sqlite ]; then
      install -m755 source/chirpstack-sqlite "$out/bin/chirpstack-sqlite"
    elif [ -f source/chirpstack ]; then
      # fallback if upstream ever renames it (humans love doing that)
      install -m755 source/chirpstack "$out/bin/chirpstack-sqlite"
    else
      echo "Could not find chirpstack-sqlite binary in tarball contents:" >&2
      ls -la source >&2
      exit 1
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "ChirpStack LoRaWAN Network Server (SQLite) - upstream prebuilt binary";
    homepage = "https://www.chirpstack.io/";
    license = licenses.mit;
    platforms = [ "aarch64-linux" ];
    mainProgram = "chirpstack-network-server";
  };
}

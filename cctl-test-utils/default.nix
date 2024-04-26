{ lib
, rustPlatform
, cctl
, makeWrapper
, pkg-config
, openssl
, stdenv
, darwin
, ...
}:
rustPlatform.buildRustPackage {
  pname = "cctl-test-utils";
  version = "0.0.1";
  src = ./.;
  cargoHash = "sha256-e4GpfonXNs1JItrK6idtYFaGe2wZzNueGqdPH9DTAK0=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  postInstall = ''
    wrapProgram $out/bin/cctld \
      --set PATH ${lib.makeBinPath [ cctl ]}
  '';

  nativeCheckInputs = [ cctl ];

  meta.mainProgram = "cctld";
  meta.license = lib.licenses.mit;
}

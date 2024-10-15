{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "bip39-file-converter";
  version = "0.1.0";

  src = ./.;

  cargoHash = "sha256-c7nwHjuU6NF9mXdLobNnnp5Zi2OT1AXb+8gxePs22Dw=";
  # Replace with the actual SHA256 hash of your Cargo.lock file

  nativeBuildInputs = [ ];

  buildInputs = [ ];

  meta = with lib; {
    description = "A tool to convert files to BIP39 mnemonics and back";
    homepage = "https://github.com/your-github-username/bip39-file-converter";
    license = licenses.mit; # Adjust if you're using a different license
    maintainers = with maintainers; [ your-name ];
  };
}

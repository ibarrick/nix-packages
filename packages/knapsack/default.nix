{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "knapsack";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.rustc ];

  buildPhase = ''
    rustc main.rs -o knapsack
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv knapsack $out/bin/
  '';
}

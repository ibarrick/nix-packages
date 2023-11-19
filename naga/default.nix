# This imports the nix package collection,
# so we can access the `pkgs` and `stdenv` variables
{ stdenv, pkgs, ...}:
with pkgs;
# Make a new "derivation" that represents our shell
stdenv.mkDerivation {
  name = "naga-keybindings";

  src = fetchFromGitHub {
	owner = "ibarrick";
	repo = "Razer_Mouse_Linux";
	rev = "97804f4f35bacc9c4b0b7d833d36652db8cd928b";
	sha256 = "sha256-WRT77qbsKRiI+MnO0KasQqVg4o6UXSck1SqVWKhSu4I=";
  };

  buildInputs = [gcc9 xdotool];
  nativeBuildInputs = [ xdotool makeWrapper ];
  propagatedNativeBuildInputs = [xdotool];
  propagatedBuildInputs = [ xdotool ];

  buildPhase = ''
	g++ -pthread -Ofast --std=c++2a src/naga.cpp -o naga
  '';

  installPhase = ''
	mkdir -p $out/lib/udev/rules.d
	echo 'KERNEL=="event[0-9]*",SUBSYSTEM=="input",GROUP="razer",MODE="640"' > $out/lib/udev/rules.d/80-naga.rules
	mkdir -p $out/bin
	mv naga $out/bin/
	chmod +x $out/bin/naga
	makeWrapper ${xdotool}/bin/xdotool $out/bin/xdotool 
  '';

}

# This imports the nix package collection,
# so we can access the `pkgs` and `stdenv` variables
{ lib, stdenv, wtype }:

stdenv.mkDerivation rec {
  pname = "razer-naga-key-modifier";
  version = "0.1.0";

  src = ./.;  # Use the current directory as the source

  buildInputs = [ wtype ];
  nativeBuildInputs = [ wtype makeWrapper ];
  propagatedNativeBuildInputs = [wtype];
  propagatedBuildInputs = [ wtype ];


  buildPhase = ''
    $CC -o naga src/naga.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp naga $out/bin/
 	makeWrapper ${wtype}/bin/wtype $out/bin/wtype 

  '';

  meta = with lib; {
    description = "A key modifier for Razer Naga V2 Pro that simulates Windows key presses";
    license = licenses.mit; # Adjust as necessary
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Add maintainers if applicable
  };
}

# Version 2 of 2
# # Make a new "derivation" that represents our shell
# stdenv.mkDerivation {
#   name = "naga-keybindings";

#   src = fetchFromGitHub {
# 	owner = "ibarrick";
# 	repo = "Razer_Mouse_Linux";
# 	rev = "46367ced4c6458bb4b2525a512e96251b448b2b7";
# 	sha256 = "1aqzas6fji4x2i2m4xrgb4k6xaqw173gybs65xvjdpavn8ldfdp7";
#   };

#   buildInputs = [gcc wtype];
#   nativeBuildInputs = [ wtype makeWrapper ];
#   propagatedNativeBuildInputs = [wtype];
#   propagatedBuildInputs = [ wtype ];

#   buildPhase = ''
# 	gcc -pthread -Ofast naga.c -o naga
#   '';

#   installPhase = ''
# 	mkdir -p $out/bin
# 	mv naga $out/bin/
# 	chmod +x $out/bin/naga
# 	makeWrapper ${xdotool}/bin/wtype $out/bin/wtype 
#   '';

# }

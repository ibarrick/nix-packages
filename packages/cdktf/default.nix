{ pkgs, stdenv, ... }:
pkgs.mkYarnPackage rec {
  name = "cdktf";
  src = pkgs.fetchFromGitHub {
    owner = "hashicorp";
    repo = "terraform-cdk";
    rev = "cae7025a7f612c8c09c3590a2bf51cb65b3173dd";
    sha256 = "sha256-zPn9OyXFdHVvAlRmOEU11/Uw1wllCUoLmD/vq2KiwTc=";
  };

  buildPhase = ''
    runHook preBuild

    yarn build

    runHook postBuild
  '';

#  packageJSON = "${src}/package.json";
#  yarnLock = "${src}/yarn.lock";
}

# stdenv.mkDerivation rec {
#   name = "cdk8s";

#   src = pkgs.fetchFromGitHub {
#     owner = "cdk8s-team";
#     repo = "cdk8s-cli";
#     rev = "6a8f845ee1b9a82c375af9d0b0d50d85d94e5f39";
#     sha256 = "sha256-RXagt84TyI8Q9SDWt+NkEDO3Nya1MY5JzRDmOXF0CuM=";
#   };

#   offlineCache = pkgs.fetchYarnDeps {
#     yarnLock = src + "/yarn.lock";
#     sha256 = "sha256-BYETtLoAvW2jMKe05qbNkKQ7ocL9+1vai58AyAmIXNM=";
#   };
 
#   buildInputs = [ pkgs.yarn ];

#   configurePhase = ''
#     cp -r "$node_modules" node_modules
#     chmod -R u+w node_modules
#   '';

#   buildPhase = ''
#     yarn --offline
#     yarn compile
#   '';

#   installPhase = ''
#     mkdir -p $out/bin
#     mv bin/cdk8s $out/bin/
#     chmod +x $out/bin/cdk8s
#   '';
# }

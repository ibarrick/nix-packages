# This imports the nix package collection,
# so we can access the `pkgs` and `stdenv` variables

{ stdenv }:
stdenv.mkDerivation {
  name = "ghostpdl";

  src = fetchTarball {
    url = "https://miscservisuite.s3.amazonaws.com/ghostpdl-9.54.0.tar.gz";
    sha256 = "1j9swbly0nimar8cls6xf8y1lpd77v36pnpymqpzrkdwg3mj4438";
  };

  postInstall = ''
    ln -s gpcl6 "$out"/bin/pcl6
  '';
}

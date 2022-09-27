{
  description = "ibarrick Nix Packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05"; 

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = 
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
# can't get this to work anymore?
#      hello = nixpkgs.legacyPackages.x86_64-linux.hello;

      ghostpdl = import ./ghostpdl { stdenv = pkgs.stdenv; };
    };

  };
}

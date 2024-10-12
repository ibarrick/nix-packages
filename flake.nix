{
  description = "ibarrick Nix Packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { system = system; config = { allowUnfree = true; }; };
        in
        {
          packages = {

            neovim = pkgs.callPackage ./packages/neovim { };

            ghostpdl = pkgs.callPackage ./packages/ghostpdl { };

            naga = pkgs.callPackage ./packages/naga { };
            
            cdk8s = pkgs.callPackage ./packages/cdk8s { };

            usql = pkgs.callPackage ./packages/usql { };

            anytype = pkgs.callPackage ./packages/anytype { };

            jaspersoft-studio = pkgs.callPackage ./jasper { };
        };

        nixosModules.naga = import ./modules/naga.nix;
      
      }
  );

}

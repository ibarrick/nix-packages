{
  description = "ibarrick Nix Packages";

  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 

    swww.url = "github:LGFae/swww";
  };

  outputs = { self, nixpkgs, stable, swww }: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsFor = system: import nixpkgs { 
          inherit system; 
          config.allowUnfree = true;
      };
      stablePkgsFor = system: import stable { 
          inherit system; 
          config.allowUnfree = true;
      };

      mkCustomPackages = system:
        let pkgs = pkgsFor system;
        in {
          neovim = pkgs.callPackage ./packages/neovim { };

          ghostpdl = pkgs.callPackage ./packages/ghostpdl { };

          naga = pkgs.callPackage ./packages/naga { };

          cdk8s = pkgs.callPackage ./packages/cdk8s { };

          usql = pkgs.callPackage ./packages/usql { };

          anytype = pkgs.callPackage ./packages/anytype { };

          jaspersoft-studio = pkgs.callPackage ./jasper { };
        };

    in {

      packages = forAllSystems mkCustomPackages;

      nixosModules = {
        dotfiles = ./modules/dotfiles.nix;
      };

      nixosConfigurations = {

          # Desktop
          nixos = stable.lib.nixosSystem {
              system = "x86_64-linux";

              modules = [
                  ./lib/base-system.nix
                  ./lib/gui-system.nix
                  ./machines/desktop.nix
              ];

              specialArgs = {
                  username = "ian";
                  inherit swww;
                  pkgs = stablePkgsFor "x86_64-linux";
                  unstablePkgs = pkgsFor "x86_64-linux";
                  customPackages = self.packages.x86_64-linux;
              };
          };

      };
    };

}

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

      specialArgsFor = system: {
        username = "ian";
        inherit swww;
        pkgs = stablePkgsFor system;
        unstablePkgs = pkgsFor system;
        customPackages = self.packages.${system};
      };


      mkCustomPackages = system:
        let pkgs = pkgsFor system;
        in {
          neovim = pkgs.callPackage ./packages/neovim { };

          ghostpdl = pkgs.callPackage ./packages/ghostpdl { };

          naga = pkgs.callPackage ./packages/naga { };

          cdk8s = pkgs.callPackage ./packages/cdk8s { };

          usql = pkgs.callPackage ./packages/usql { };

          anytype = pkgs.anytype;

          jaspersoft-studio = pkgs.callPackage ./jasper { };

          bip39 = pkgs.callPackage ./packages/bip39 {};
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

              specialArgs = specialArgsFor "x86_64-linux";
          };

          # Live USB
          usb = stable.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ./lib/base-system.nix
              ./lib/gui-system.nix
              "${stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ./machines/usb.nix
            ];

            specialArgs = specialArgsFor "x86_64-linux";

          };

      };
    };

}

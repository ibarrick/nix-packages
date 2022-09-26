{
  description = "ibarrick Nix Packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05"; 

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = {
      hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    };

  };
}

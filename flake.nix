{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... } @ inputs:
  let
    vars = import ./vars.nix;
    mkNixos = nixpkgs.lib.nixosSystem;
  in {
    nixosConfigurations = {
      vps1 = mkNixos {
        specialArgs = { inherit inputs disko vars; };
        system = "x86_64-linux";
        modules = [ ./machines/vps1/configuration.nix ];
      };
    };
  };
}

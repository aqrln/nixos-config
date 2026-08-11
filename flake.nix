{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    selenized = {
      url = "github:jan-warchol/selenized";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      install-vetiver = import ./install-vetiver.nix { inherit disko pkgs system; };
    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-tree;

      apps.${system}.install-vetiver = {
        type = "app";
        program = "${install-vetiver}/bin/install-vetiver";
      };

      packages.${system}.install-vetiver = install-vetiver;

      nixosConfigurations.vetiver = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs.inputs = inputs;
        modules = [
          disko.nixosModules.disko
          ./disko.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.aqrln = ./home.nix;
          }
        ];
      };
    };
}

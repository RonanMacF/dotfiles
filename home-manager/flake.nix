{
  description = "Ronan's dotfiles — nix-darwin (macOS) + home-manager (cross-platform)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zsh plugins not in nixpkgs
    zsh-auto-notify = {
      url = "github:MichaelAquilina/zsh-auto-notify";
      flake = false;
    };
    git-extra-commands = {
      url = "github:unixorn/git-extra-commands";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }@inputs: {

    # macOS — nix-darwin with home-manager as module
    darwinConfigurations."Ronans-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.ronan = import ./home.nix;
        }
      ];
    };

    # Linux — standalone home-manager
    homeConfigurations."ronan@ronan-vm" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
  };
}

{
  description = "Ronan's home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      mkHomeConfig = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home.nix ];
        };
    in
    {
      homeConfigurations = {
        # home-manager auto-detects by username
        "ronan" = mkHomeConfig builtins.currentSystem;
      };
    };
}

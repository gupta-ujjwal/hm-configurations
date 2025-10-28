{
  description = "Home Manager configuration of Ujjwal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin"; 
      username = "Ujjwal.gupta";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.hm = home-manager.packages.${system}.default;
      # homeConfigurations must be an attribute set
      homeConfigurations = {
        ${username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit system username; };
     
          modules = [ ./home.nix ./neovim.nix ./tmux.nix ./tmate.nix ];
        };        
        default = self.homeConfigurations.${username};  
      };

    };
}

{
  description = "Home Manager configuration of Ujjwal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    AI.url = "github:srid/AI";
  };

  outputs = { self, nixpkgs, home-manager, AI, ... }:
    let
      system = "x86_64-linux"; 
      username = "vishal";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.hm = home-manager.packages.${system}.default;
      # homeConfigurations must be an attribute set
      homeConfigurations = {
        ${username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit system username AI; };
     
          modules = [ ./home.nix ./neovim.nix ./tmux.nix ./tmate.nix ./redis.nix ];
        };        
        default = self.homeConfigurations.${username};  
      };

    };
}

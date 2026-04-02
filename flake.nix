{
  description = "Home Manager configuration of Ujjwal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-agent-wire.url = "github:srid/nix-agent-wire";
    juspay-AI.url = "github:juspay/AI";
  };

  outputs = { self, nixpkgs, home-manager, nix-agent-wire, juspay-AI, ... }:
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
          extraSpecialArgs = { inherit system username nix-agent-wire juspay-AI; };
     
          modules = [ ./home.nix ./modules/neovim.nix ./modules/tmux.nix ./modules/tmate.nix ./modules/redis.nix ];
        };        
        default = self.homeConfigurations.${username};  
      };

    };
}

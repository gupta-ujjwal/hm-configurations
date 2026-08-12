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
    kolu.url = "github:juspay/kolu";  # pinned to stable; master is switching to effect-ts
    euler-workspace.url = "git+ssh://git@ssh.bitbucket.juspay.net/~ujjwal.gupta_juspay.in/euler-workspace.git?ref=euler-skills";
  };

  outputs = { self, nixpkgs, home-manager, nix-agent-wire, juspay-AI, kolu, euler-workspace, ... }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems f;

      # Auto-detect user/home via env (requires --impure), with sensible fallbacks
      username = let env = builtins.getEnv "USER"; in if env != "" then env else "Ujjwal.gupta";
      homeDir = let env = builtins.getEnv "HOME"; in if env != "" then env else "/Users/${username}";

      mkHome = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit system username nix-agent-wire juspay-AI kolu euler-workspace; };
          modules = [ ./home.nix ./modules/neovim.nix ./modules/tmux.nix ./modules/tmate.nix ./modules/redis.nix ./modules/obsidian.nix ./modules/apm.nix ./modules/kolu.nix ./modules/daily-brief.nix ];
        };
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          hm = home-manager.packages.${system}.default;
          bootstrap = pkgs.writeShellScriptBin "bootstrap" (builtins.readFile ./bootstrap.sh);
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.bootstrap}/bin/bootstrap";
        };
      });

      homeConfigurations = {
        ${username} = mkHome (
          let env = builtins.getEnv "NIX_SYSTEM";
          in if env != "" then env else builtins.currentSystem or "aarch64-darwin"
        );
        default = self.homeConfigurations.${username};
      };
    };
}

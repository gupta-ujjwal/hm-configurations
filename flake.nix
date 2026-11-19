{
  description = "Home Manager configuration of Ujjwal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Prebuilt weekly nix-index database (command-not-found / nix-locate)
    # instead of an empty DB that would need a ~30 min local `nix-index` run.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    juspay-AI.url = "github:juspay/AI";
    kolu.url = "github:juspay/kolu";  # pinned to stable; master is switching to effect-ts
  };

  outputs = { self, nixpkgs, home-manager, nix-index-database, juspay-AI, kolu, ... }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs supportedSystems f;

      # Auto-detect user/home via env (requires --impure), with sensible fallbacks
      username = let env = builtins.getEnv "USER"; in if env != "" then env else "Ujjwal.gupta";

      currentSystem =
        let env = builtins.getEnv "NIX_SYSTEM";
        in if env != "" then env else builtins.currentSystem or "aarch64-darwin";

      # Per-machine configs, exposed as "<user>@<hostname>". `home-manager switch
      # --flake .` picks "$USER@$(hostname)" automatically and falls back to "$USER".
      # user/system are spelled out (not read from env) because home-manager probes
      # the attribute names with a *pure* `nix eval`, where getEnv returns "".
      hosts = {
        "ujjwal-gupta-X510UNR" = {  # Linux laptop doubling as home server
          user = "ujjwal-gupta";
          system = "x86_64-linux";
          module = ./hosts/x510unr.nix;
        };
      };

      mkHome = { system, username, hostModules ? [ ] }:
        home-manager.lib.homeManagerConfiguration {
          # Import nixpkgs once with our config. Setting `nixpkgs.config` inside a
          # HM module instead makes HM import nixpkgs a second time.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit system username juspay-AI kolu; };
          modules = [
            nix-index-database.homeModules.nix-index
            ./home.nix
            ./modules/neovim.nix
            ./modules/tmux.nix
            ./modules/tmate.nix
            ./modules/redis.nix
            ./modules/obsidian.nix
            ./modules/apm.nix
            ./modules/kolu.nix
            ./modules/daily-brief.nix
            ./modules/dia.nix
            ./modules/system-setup.nix
            ./modules/podman.nix
            ./modules/home-server.nix
          ] ++ hostModules;
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
        ${username} = mkHome { inherit username; system = currentSystem; };
        default = self.homeConfigurations.${username};
      } // lib.mapAttrs' (host: h:
        lib.nameValuePair "${h.user}@${host}" (mkHome {
          inherit (h) system;
          username = h.user;
          hostModules = [ h.module ];
        })
      ) hosts;
    };
}

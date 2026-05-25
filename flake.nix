{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    # agenix.url = "github:ryantm/agenix";
    # claude-desktop = {
    #   url = "github:k3d3/claude-desktop-linux-flake";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     flake-utils.follows = "flake-utils";
    #   };
    # };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      # url = "github:zhaofengli/nix-homebrew";
      url = "github:slickag/nix-homebrew/brew-latest-patch-1";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-cirruslabs = {
      url = "github:cirruslabs/homebrew-cli";
      flake = false;
    };
    # homebrew-cloudflare = {
    #   url = "github:cloudflare/homebrew-cloudflare";
    #   flake = false;
    # };
    homebrew-hashicorp = {
      url = "github:hashicorp/homebrew-tap";
      flake = false;
    };
    homebrew-brews = {
      url = "github:otsge/homebrew-brews";
      flake = false;
    };
    homebrew-casks = {
      url = "github:otsge/homebrew-casks";
      flake = false;
    };
    # homebrew-wailbrew = {
    #   url = "github:wickenico/homebrew-wailbrew";
    #   flake = false;
    # };
    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # secrets = {
    #   url = "git+ssh://git@github.com/slickag/nix-secrets.git";
    #   flake = false;
    # };
    # chaotic = {
    #   url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs = inputs@{ self, darwin, nix-homebrew, home-manager, mac-app-util, nixpkgs, flake-utils, ... }:
    let
      user = "AG";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          # nativeBuildInputs = with pkgs; [ bashInteractive git age age-plugin-yubikey ];
          nativeBuildInputs = with pkgs; [ bashInteractive git ];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName} "$@"
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "build-switch-emacs" = mkApp "build-switch-emacs" system;
        "clean" = mkApp "clean" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "clean" = mkApp "clean" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };
    in
    {
      templates = {
        starter = {
          path = ./templates/starter;
          description = "Starter configuration without secrets";
        };
        # starter-with-secrets = {
          # path = ./templates/starter-with-secrets;
          # description = "Starter configuration with secrets";
        # };
      };
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs // { inherit user; };
          modules = [
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            (
              { pkgs, config, inputs, ... }:
              {
                home-manager.sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];
              }
            )
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                # enableRosetta = true;
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "cirruslabs/homebrew-cli" = inputs.homebrew-cirruslabs;
                  # "cloudflare/homebrew-cloudflare" = inputs.homebrew-cloudflare;
                  "hashicorp/homebrew-tap" = inputs.homebrew-hashicorp;
                  "otsge/homebrew-brews" = inputs.homebrew-brews;
                  "otsge/homebrew-casks" = inputs.homebrew-casks;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ({config, ...}: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
            ./hosts/darwin
          ];
        }
      );
      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs // { inherit user; };
          modules = [
            # disko.nixosModules.disko
            # chaotic.nixosModules.default
            home-manager.nixosModules.home-manager {
              home-manager = {
                # sharedModules = [ plasma-manager.homeModules.plasma-manager ]; 
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = { config, pkgs, lib, ... }:
                  import ./modules/nixos/home-manager.nix { inherit config pkgs lib inputs; };
              };
            }
            ./hosts/nixos
          ];
        }
      );
    };
}

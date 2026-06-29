{
  description = "Nix flake for Limux — GPU-accelerated terminal workspace manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: {
        limux = final.callPackage ./packages/limux.nix { };
      };

      packages = forAllSystems (
        { pkgs, ... }:
        {
          inherit (pkgs) limux;
          default = pkgs.limux;
        }
      );

      apps = forAllSystems (
        { pkgs, ... }:
        {
          default = {
            type = "app";
            program = "${pkgs.limux}/bin/limux";
          };
        }
      );

      nixosModules.default =
        { config, lib, ... }:
        {
          options.programs.limux.enable = lib.mkEnableOption "Limux terminal workspace manager";

          config = lib.mkIf config.programs.limux.enable {
            environment.systemPackages = [ self.packages.${config.nixpkgs.hostPlatform.system}.limux ];
          };
        };

      homeManagerModules.default =
        { config, lib, ... }:
        {
          options.programs.limux.enable = lib.mkEnableOption "Limux terminal workspace manager";

          config = lib.mkIf config.programs.limux.enable {
            home.packages = [ self.packages.${config.nixpkgs.hostPlatform.system}.limux ];
          };
        };

      devShells = forAllSystems (
        { pkgs, system, ... }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nix-update
            ];
            shellHook = ''
              echo "limux-nix dev shell (${system})"
              echo "  nix build .#limux"
              echo "  nix run github:Mic92/nix-update -- limux --flake --build"
            '';
          };
        }
      );

      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixfmt);
    };
}

# limux-nix

Unofficial [Nix](https://nixos.org) flake packaging for [Limux](https://github.com/am-will/limux) on NixOS and other Nix-based systems.

Limux ships pre-built Linux binaries that depend on host GTK4, libadwaita, and WebKitGTK libraries. This flake wraps the upstream release tarball, patches it for NixOS, and wires in the required runtime dependencies — addressing [am-will/limux#75](https://github.com/am-will/limux/issues/75).

## Quick start

Run without installing:

```bash
nix run github:crowquillx/limux-nix
```

Install into your profile:

```bash
nix profile install github:crowquillx/limux-nix
```

Build locally:

```bash
nix build .#limux
./result/bin/limux -h
```

Enter a dev shell with `nix-update` available:

```bash
nix develop
```

## NixOS

Add the flake as an input and enable the module:

```nix
{
  inputs.limux-nix.url = "github:crowquillx/limux-nix";

  outputs = { nixpkgs, limux-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        limux-nix.nixosModules.default
        { programs.limux.enable = true; }
      ];
    };
  };
}
```

Or use the overlay directly:

```nix
{
  inputs.limux-nix.url = "github:crowquillx/limux-nix";

  outputs = { nixpkgs, limux-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ limux-nix.overlays.default ];
          environment.systemPackages = [ pkgs.limux ];
        }
      ];
    };
  };
}
```

## Home Manager

```nix
{
  imports = [ limux-nix.homeManagerModules.default ];
  programs.limux.enable = true;
}
```

## Automation

This repository includes GitHub Actions workflows:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **Build** | push, PR, manual | Runs `nix flake check`, builds the package, uploads a CI artifact |
| **Update upstream** | daily cron, manual | Uses [nix-update](https://github.com/Mic92/nix-update) to bump the version/hash when a new upstream release is published, opens a PR, and verifies the build |
| **Update flake.lock** | weekly cron, manual | Refreshes the `nixpkgs` pin and opens a PR when inputs change |
| **Release** | version tag, manual | Builds the package and publishes a GitHub release with a tarball |

To update manually:

```bash
nix run github:Mic92/nix-update -- limux --flake --build
```

Format Nix files:

```bash
nix fmt
```

## Publishing this repository

After cloning locally:

```bash
git init -b main
git add .
git commit -m "Initial commit: Nix flake for Limux"
chmod +x scripts/publish-github.sh
./scripts/publish-github.sh
```

## Optional: Cachix binary cache

CI can push built packages to [Cachix](https://cachix.org) when `CACHIX_AUTH_TOKEN` is configured as a repository secret. The cache name is `crowquillx`.

Users can then install with:

```bash
cachix use crowquillx
nix profile install github:crowquillx/limux-nix
```

## Platform support

Currently wired for `x86_64-linux` only (matches upstream release tarballs today).

## License

MIT — same as upstream Limux.

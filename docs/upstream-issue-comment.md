Suggested comment for https://github.com/am-will/limux/issues/75

---

For NixOS users: there's now a community flake that wraps the official Linux tarball with the required GTK4/libadwaita/WebKitGTK dependencies and auto-updates when new releases are published:

https://github.com/crowquillx/limux-nix

```bash
nix run github:crowquillx/limux-nix
```

Or on NixOS with the included module:

```nix
inputs.limux-nix.url = "github:crowquillx/limux-nix";
# ...
programs.limux.enable = true;
```

Based on the packaging approach from @whazor's comment above. Happy to upstream this into nixpkgs if maintainers prefer.

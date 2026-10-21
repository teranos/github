{
  description = "qntx-github: GitHub integration for repository events, a QNTX plugin";

  # The node builds this plugin in `nix shell --inputs-from <this repo> nixpkgs#go`
  # (QNTX ADR-002), so this pin is the nixpkgs the build runs with. It is QNTX's own.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/fb7944c166a3b630f177938e478f0378e64ce108";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      each = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = each (pkgs: {
        default = pkgs.mkShell { packages = [ pkgs.go pkgs.gnumake ]; };
      });
    };
}

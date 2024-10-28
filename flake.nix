{
  description = "A Nix-flake-based Haskell development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default =
          let
            ghc = pkgs.haskell.packages.ghc92.ghc;
            hls = pkgs.haskell-language-server.override {
              supportedGhcVersions = [ "92" ];
            };
          in
          pkgs.mkShell {
            packages = [ ghc hls ] ++ (with pkgs; [
              stack
              cabal-install
              hlint
            ]);
          };
      });
    };
}

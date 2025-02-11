{
  description = "A Nix-flake-based Haskell development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default =
            let
              haskellPackages = pkgs.haskell.packages.ghc96;
            in
            pkgs.mkShell rec {
              buildInputs =
                (with haskellPackages; [
                  ghc
                  haskell-language-server
                ])
                ++ (with pkgs; [
                  stack
                  cabal-install
                  hlint
                  pkg-config
                  zlib
                ]);
              # Ensure that libz.so and other libraries are available to TH
              # splices, cabal repl, etc.
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
            };
        }
      );
    };
}

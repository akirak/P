{
  description = "Nix flake for the P programming language";

  inputs.nixpkgs.url = "nixpkgs";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});
    in
    {
      packages = eachSystem (
        _system: pkgs:
        let
          p = pkgs.callPackage ./nix/package.nix { src = self; };
        in
        {
          default = p;
          p = p;
        }
      );

      devShells = eachSystem (
        system: pkgs:
        let
          inherit (pkgs)
            dotnetCorePackages
            jdk17
            maven
            mkShell
            ;
        in
        {
          default = mkShell {
            packages = [
              self.packages.${system}.default
              dotnetCorePackages.sdk_8_0
              jdk17
              maven
            ];
          };
        }
      );
    };
}

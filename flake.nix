{
  description = "Neovim Comment Divider Plugin";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem [
      system.x86_64-linux
      system.x86_64-darwin
      system.aarch64-darwin
    ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.default = pkgs.mkShell
            {
              buildInputs = with pkgs; [
                stylua
              ];
            };
        }
      );
}

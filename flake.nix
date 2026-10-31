{
  description = "Development launcher for comment-divider.nvim";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
          (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        docs = pkgs.writeShellScriptBin "comment-divider-docs" ''
          set -eu
          mkdir -p doc
          ${pkgs.panvimdoc}/bin/panvimdoc \
            --project-name comment-divider --input-file README.md \
            --no-date true --no-vim-version true
          exec ${pkgs.neovim-unwrapped}/bin/nvim --headless -u NONE -n -i NONE \
            -c 'try | helptags doc | catch | cquit 1 | endtry' -c 'qa!'
        '';

        test = pkgs.writeShellScriptBin "comment-divider-test" ''
          export PLENARY_DIR=${pkgs.vimPlugins.plenary-nvim}
          exec ${pkgs.neovim-unwrapped}/bin/nvim --headless --noplugin -n -i NONE \
            -u tests/minimal_init.lua \
            -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
        '';

        dev = pkgs.writeShellScriptBin "comment-divider-dev" ''
          export COMMENT_DIVIDER_ROOT="$PWD"
          editor="$(command -v nvim || true)"
          exec "''${editor:-${pkgs.neovim}/bin/nvim}" \
            -c 'lua vim.opt.runtimepath:prepend(vim.env.COMMENT_DIVIDER_ROOT)' \
            -c 'lua for name in pairs(package.loaded) do if name == "comment-divider" or name:match("^comment%-divider%.") then package.loaded[name] = nil end end' \
            -c 'lua vim.g.loaded_comment_divider = nil' \
            -c 'runtime plugin/comment-divider.lua' \
            -c 'lua require("comment-divider").setup()' \
            "$@"
        '';
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.stylua ];
        };
      });

      formatter = forAllSystems (
        pkgs:
        pkgs.writeShellScriptBin "format-lua" ''
          exec ${pkgs.stylua}/bin/stylua lua plugin tests "$@"
        ''
      );
    };
}

# Repository Guidelines

## Scope

Solve the whole requested problem with the least new code. Read affected callers,
configuration, documentation, and tests before editing. Preserve public APIs and
validation; do not add unrelated features or abstractions. Test nontrivial changes.
Report anything not checked and any remaining risk.

## Project Structure

This is a Lua Neovim plugin with no runtime dependencies. Keep the public API in
`lua/comment-divider/init.lua`, styles in `lua/comment-divider/comment-config.lua`,
generation in `lua/comment-divider/comment-generator.lua`, commands in `plugin/`,
and Plenary/Busted tests in `tests/` using `*_spec.lua` filenames.

Preserve the existing camelCase Lua API, current configuration keys,
`CommentDivider` subcommands, and cumulative `setup()` semantics. Do not
reintroduce removed configuration aliases. Use snake_case for new private
functions and variables. The `reload()` development helper clears the plugin
modules without requiring Plenary; it resets configuration on next load.

Keep README.md user-facing: installation, configuration, and usage. Document
development processes and requirements here, updating this file when they change.

## Development

Requires Nix with the `nix-command` and `flakes` experimental features enabled.
There is no build step. Nix provides tools and Plenary, which is a test dependency only.

```sh
# Install the pre-commit hook.
git config core.hooksPath .githooks

# Open your normal Neovim with this checkout loaded and setup() called.
nix run .#dev

# Run isolated Plenary/Busted tests.
nix run .#test

# Regenerate help and tags from README.md.
nix run .#docs

# Format Lua, or check formatting without writing.
nix fmt
nix fmt -- --check
```

The launcher preserves your Neovim configuration and supplies Neovim if needed.
After configuration loads, it prioritizes this checkout, clears cached plugin
modules, and registers the local commands again to replace any installed copy.
Restart after edits. `nix develop` supplies StyLua and supports `.envrc`/direnv.

The hook checks formatting, runs tests, and regenerates `doc/comment-divider.txt`.
Stage updated help before retrying a commit. `doc/tags` is generated and ignored.
Regenerate help whenever README.md changes.

Git-backed flakes only include files added to Git. Add new files before using the
commands above, or use `nix run path:.#test`, `nix run path:.#docs`, and
`nix run path:.#formatter.aarch64-darwin -- --check` for an untracked checkout
(replace the system name as needed).

## Coding Style and Contributions

Follow `.stylua.toml`: two-space indentation, Unix line endings, a 120-column
width, and preferred double quotes. Put comments above the code they describe.
Return module tables. Keep changes focused, retain the license notice, update
tests for behavior changes, and document public changes in README.md and help.

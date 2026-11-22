# CLAUDE.md

macOS-primary dotfiles repo using [dotbot](https://github.com/anishathalye/dotbot) for symlink management.

## Structure

- `meta/configs/*.yaml` -- dotbot config files; each declares symlinks for one tool (git, zsh, vim, etc.)
- `meta/profiles/{mac,linux}` -- newline-delimited lists of config names to apply per OS
- `meta/base.yaml` -- shared dotbot defaults (create dirs, relink, clean stale symlinks)
- `meta/dotbot/` -- dotbot git submodule; do not edit directly
- `bootstrap/bootstrap.sh` -- full system setup (homebrew, pyenv, oh-my-zsh, rust, fonts, macOS prefs)
- `homebrew/Brewfile.{base,personal,work}` -- brew bundle files, selected interactively during bootstrap
- `bin/test` -- runs shellcheck, shfmt, yamllint
- Private config (Herdr dispatch setup, SSH hosts, Claude hooks) is NOT here: this repo is public.
  It lives in the private repo `jamescurtin/dotfiles-private`, with its own `install`.
- `bin/update-bootstrap-sha` -- regenerates SHA256 in README.md; must run after editing bootstrap.sh

## Installation

- `./install-profile mac` or `./install-profile linux` -- applies the named profile via dotbot
- `./install-standalone <config> [config...]` -- applies individual configs without a profile
- `./bootstrap/bootstrap.sh` -- full machine provisioning (interactive, requires sudo)

## Linting and CI

- CI runs on every push: yamllint, shellcheck, shfmt, and SHA256 verification
- Local: `bin/test` runs the same checks (requires shellcheck, shfmt, yamllint installed)
- Shell formatting: `.editorconfig` enforces 4-space indent, bash variant, `shfmt -s`
- YAML formatting: `.yamllint` config; double quotes only-when-needed, 84-char line warning

## Constraints

- dotbot is a git submodule at `meta/dotbot`; after clone use `--recursive` or run `git submodule update --init --recursive`
- Editing `bootstrap/bootstrap.sh` requires running `bin/update-bootstrap-sha` and committing the README.md change; CI will fail otherwise
- All commits to the repo are signed
- macOS-specific configs (hammerspoon, iterm2, gpg.mac, vscode.mac) are only in the `mac` profile
- Renovate (`renovate.json`) manages dependency updates for CI actions and tool versions

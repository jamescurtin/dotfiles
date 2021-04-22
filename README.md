# dotfiles

![Linting](https://github.com/jamescurtin/dotfiles/workflows/Linting/badge.svg)

This repo is optimized for MacOS, though it does have limited support for other operating systems.

## Full system configuration

To fully configure a new system (including installing system dependencies, mac apps, etc.)
in addition to creating dotfiles, run the following bootstrap script:

From the cloned repo:
```bash
$ ./bootstrap.sh
```

To run as a one-liner:
```bash
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/jamescurtin/dotfiles/master/bootstrap/bootstrap.sh)"
```
(sha256 checksum: `d3d1f13d979fe8aa315095a948f6c42235787375d583e5372a474ff9e1d3e58c`: all commits to this repository will be signed.)


## Dotfile Installation

Clone the repo recursively:

```bash
git clone --recursive git@github.com:jamescurtin/dotfiles.git ~/repos/dotfiles
```

Install the correct profile for the target OS (`mac`, `linux`)

```bash
$ cd ~/repos/dotfiles
./install-profile mac
```

## Testing

```bash
$ ./test.sh
```

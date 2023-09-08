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
(sha256 checksum: `58fd67f24090858e3aa6095c0a1ef441f7b6252a5cbbb57d38abdcb89ef1cd86`: all commits to this repository will be signed.)


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

## Developing and Testing

If you update the `bootstrap/bootstrap.sh` file, you must also run

```bash
bin/update-bootstrap-sha
```

To run all lints and tests:
```bash
bin/test
```

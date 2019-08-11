# dotfiles

This repo is optimized for MacOS, though it does have limited support for other operating systems.

## Full system configuration

To fully configure a new system (including installing system dependencies, mac apps, etc)
in addition to creating dotfiles, run the following bootstrap script:

```bash
$ ./bootstrap.sh
```
## Installation

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

## TODOs

* Dropbox symlinks
* Better VS Code dotfiles

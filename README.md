# dotfiles

This repo is optimized for MacOS, though it does have limited support for other operating systems.

## Pre-Installation (MacOS)

- Install homebrew and cask

  ```bash
  $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  $ brew install caskroom/cask/brew-cask
  $ brew tap caskroom/versions
  ```

- Install tools

  ```bash
  $ brew install vim tmux git python zsh zsh-completions
  ```

- Install oh-my-zsh

  ```bash
  $ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  ```

- Install apps

  ```bash
  $ brew cask install visual-studio-code sublime-text iterm2
  ```

- Install `tmux-plugins`

  ```bash
  $ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ```

- Install `pathogen`

  ```bash
  $ mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
  ```

- Install `powerline`

  ```bash
  $ pip install powerline-status
  ```

- Install `Powerline fonts`

  ```bash
  # clone
  $ git clone https://github.com/powerline/fonts.git
  $ cd fonts
  $ ./install.sh
  $ cd ..
  $ rm -rf fonts
  ```

- Remove existing dotfiles in preparation for symlinking to this repo (**NOTE**: Only do this if you are sure, as you will lose your existing dotfiles.)

  ```bash
  $ rm -f ~/.zshrc ~/.vimrc ~/.tmux.conf ~/.gitconfig ~/.bash_profile ~/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings ~/.config/Code/User/settings.json ~/Library/Application Support/Code/User/settings.json ~/.oh-my-zsh/custom/zsh_function.zsh  ~/.oh-my-zsh/custom/zsh_alias.zsh
  ```

## Installation

Make sure to install the repo recursively, as in:

```bash
git clone --recursive git@github.com:jamescurtin/dotfiles.git ~/repos/dotfiles
```

You would then need to install a particular profile via

```bash
$ cd ~/repos/dotfiles
./install-profile mac
```

## Post-installation

- Install tmux plugins
  - In a terminal, open tmux (`tmux`)
  - Install the plugins via `prefix` + `I` (where prefix is `control` + `A` at the same time)

#!/usr/bin/env bash
set -eo pipefail

export HOMEBREW_NO_ENV_HINTS=1

# For when script is invoked via curl. Makes sure full repo is available.
printf "Preparing to download dotfiles repo...\n\n"
if [[ ! -d "${HOME}/repos/dotfiles" ]]; then
    mkdir -p ~/repos
    git clone --recursive https://github.com/jamescurtin/dotfiles.git ~/repos/dotfiles
    printf "Dotfiles repo installed!\n\n"
else
    printf "Dotfiles repo was already installed!\n\n"
fi

cd ~/repos/dotfiles/bootstrap

# shellcheck source=bootstrap/messages.sh
source messages.sh
# shellcheck source=bootstrap/macos.sh
source macos.sh
# shellcheck source=bootstrap/localconfig.sh
source localconfig.sh

trap '[ "$?" -eq 0 ] || print_exit_warning' EXIT

# #################################################################################
# #                                                                               #
# #################################################################################
print_welcome_message

if [[ "$(uname)" == "Darwin" ]]; then
    OS="mac"
elif [[ "$(uname)" == "Linux" ]]; then
    OS="linux"
fi
if [[ ! ${OS:-unsupported} =~ ^(mac|linux)$ ]]; then
    bootstrap_echo "\e[91mThis script only supports macOS and linux installs. Exiting...\e[0m"
    exit 1
fi

# Prevent accidentally typing password at this point
stty -echo
bootstrap_echo "You will need to type your password to continue."
wait_for_user
stty echo
sudo -v
printf "\e[92mSuccess!\n\n\e[0m"
# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2> /dev/null &

USE_PERSONAL=0
USE_WORK=0

bootstrap_echo "Should the 'personal' profile be installed?"
echo
select yn in Yes No; do
    case $yn in
        Yes)
            USE_PERSONAL=1
            break
            ;;
        No)
            break
            ;;
    esac
done

bootstrap_echo "Should the 'work' profile be installed?"
echo
select yn in Yes No; do
    case $yn in
        Yes)
            USE_WORK=1
            break
            ;;
        No)
            break
            ;;
    esac
done

bootstrap_echo "Should the computer attempt to update its software? If an update is
available, it will be installed and \e[38;5;178myou cannot stop the process.\e[0m It may take a while."
echo "Do you want to check for updates?"
select yn in Yes No; do
    case $yn in
        Yes)
            sudo softwareupdate -i -a --restart
            break
            ;;
        No)
            printf "Skipping.\n\n"
            break
            ;;
    esac
done

bootstrap_echo "Preparing to install Homebrew 🍺"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    HOMEBREW_INSTALLED=1
fi
echo_install_status "Homebrew" "${HOMEBREW_INSTALLED:-0}"

bootstrap_echo "Preparing to install brew packages."
echo

if [ "${USE_WORK}" == "1" ]; then
    echo "Installing work brew packages"
    brew bundle --verbose --no-lock --file=../homebrew/Brewfile.work
    echo
fi

if [ "${USE_PERSONAL}" == "1" ]; then
    echo "Installing personal brew packages"
    brew bundle --verbose --no-lock --file=../homebrew/Brewfile.personal
    echo
fi

if [ "${USE_PERSONAL}" != "1" ] && [ "${USE_WORK}" != "1" ]; then
    echo "Installing base brew packages"
    brew bundle --verbose --no-lock --file=../homebrew/Brewfile.base
    echo
fi

bootstrap_echo "Final homebrew cleanup"
brew autoremove
brew cleanup

bootstrap_echo "Preparing to install oh-my-zsh"
mkdir -p "${HOME}"/.zfunc
if [[ ${ZSH} != *".oh-my-zsh"* ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    OH_MY_ZSH_INSTALLED=1
fi
echo_install_status "oh-my-zsh" "${OH_MY_ZSH_INSTALLED:-0}"

bootstrap_echo "Preparing to install tmux plugin manager"
if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    TMUX_PLUGINS_INSTALLED=1
fi
echo_install_status "tmux plugin manager" "${TMUX_PLUGINS_INSTALLED:-0}"

bootstrap_echo "Preparing to install zsh syntax highlighting"
if [[ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    ZSH_SYNTAX_INSTALLED=1
fi
echo_install_status "zsh syntax highlighting" "${ZSH_SYNTAX_INSTALLED:-0}"

PY_VERSION=$(pyenv install --list | sed 's/^  //' | grep '^\d' | grep --invert-match 'dev\|a\|b\|rc' | tail -1)
AVAILABLE_PY_VERSIONS=$(pyenv versions)
bootstrap_echo "Preparing to install python $PY_VERSION"
if [[ $AVAILABLE_PY_VERSIONS =~ ${PY_VERSION} ]]; then
    echo "python ${PY_VERSION} already installed!"
else
    LDFLAGS="-L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib" CPPFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix bzip2)/include" pyenv install -v "${PY_VERSION}"
fi
pyenv global "${PY_VERSION}"

bootstrap_echo "Preparing to install Python linting and testing packages"
pip3 install -r ../python/requirements-test.txt > /dev/null 2>&1
echo

bootstrap_echo "Preparing to install rust"
if ! command -v rustc &> /dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
else
    echo "rust already installed!"
fi

bootstrap_echo "Installing rust autocomplete"
# shellcheck source=/dev/null
source "${HOME}"/.cargo/env
rustup completions zsh > ~/.zfunc/_rustup

bootstrap_echo "Preparing to install powerline terminal status bar"
pip3 install -r ../python/requirements-terminal.txt > /dev/null 2>&1
echo

bootstrap_echo "Preparing to install powerline-compatable fonts"
install_fonts() {
    FONTS_DIR="$(mktemp -d -t fonts.XXXXXX)"
    git clone https://github.com/powerline/fonts.git "${FONTS_DIR}" &&
        "${FONTS_DIR}"/install.sh &&
        rm -rf "${FONTS_DIR}"
    echo
}
if ls -R "${HOME}"/Library/Fonts/*Powerline* > /dev/null; then
    echo "Powerline fonts already installed"
else
    install_fonts
fi

bootstrap_echo "If you have a Yubikey available, you may set it up now. If so, please
insert the yubikey before continuing."
echo "Do you want to configure a Yubikey?"
select yn in Yes No; do
    case $yn in
        Yes)
            add_yubikey
            break
            ;;
        No)
            printf "Skipping.\n\n"
            break
            ;;
    esac
done

if [[ ${OS} == "mac" ]]; then
    bootstrap_echo "Setting up macOS Dock icons."
    setup_macos_dock "${USE_WORK}" "${USE_PERSONAL}"
    printf "\e[92mSuccess!\n\n\e[0m"

    bootstrap_echo "Setting up macOS System preferences."
    setup_macos_preferences
    printf "\e[92mSuccess!\n\n\e[0m"
fi

bootstrap_echo "Installing VSCode Extensions."
configure_vscode_extensions "${USE_WORK}" "${USE_PERSONAL}"

bootstrap_echo "Installing dotfiles."
"${HOME}"/repos/dotfiles/install-profile "${OS}"
printf "\e[92mSuccess!\n\n\e[0m"

bootstrap_echo "Sourcing tmux plugins."
tmux new -d -s tmp
"${HOME}"/.tmux/plugins/tpm/bindings/install_plugins
tmux kill-session -t tmp
printf "\e[92mSuccess!\n\n\e[0m"

configure_gpg_public_keys

configure_local_gitconfig

print_exit_success

#!/usr/bin/env bash
set -eo pipefail

# For when script is invoked via curl. Makes sure full repo is available.
printf "Preparing to download dotfiles repo...\n\n"
if [[ ! -d "${HOME}/repos/dotfiles" ]]; then
    mkdir -p ~/repos
    git clone https://github.com/jamescurtin/dotfiles.git ~/repos/dotfiles
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
if [[ ! "${OS:-unsupported}" =~ ^(mac|linux)$ ]]; then
    bootstrap_echo "\e[91mThis script only supports macOS and linux installs. Exiting...\e[0m"
    exit 1
fi


bootstrap_echo "You will need to type your password to continue."
wait_for_user
sudo -v
printf "\e[92mSuccess!\n\n\e[0m"
# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


bootstrap_echo "The computer will now attempt to update its software. If an update is
available, it will be installed and \e[38;5;178myou cannot stop the process.\e[0m This may take a while."
wait_for_user
sudo softwareupdate -i -a --restart


bootstrap_echo "Preparing to install Homebrew 🍺"
if ! command -v brew &>/dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    HOMEBREW_INSTALLED=1
fi
echo_install_status "Homebrew" "${HOMEBREW_INSTALLED:-0}"


bootstrap_echo "Preparing to install brew packages."
brew bundle
echo


bootstrap_echo "Preparing to install oh-my-zsh"
if [[ "${ZSH}" != *".oh-my-zsh"* ]];then
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
    git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    ZSH_SYNTAX_INSTALLED=1
fi
echo_install_status "zsh syntax highlighting" "${ZSH_SYNTAX_INSTALLED:-0}"


bootstrap_echo "Preparing to install powerline terminal status bar"
pip3 install powerline-status
echo


bootstrap_echo "Preparing to install powerline-compatable fonts"
FONTS_DIR="$(mktemp -d -t fonts.XXXXXX)"
git clone https://github.com/powerline/fonts.git "${FONTS_DIR}" \
    && ./"${FONTS_DIR}"/install.sh \
    && rm -rf "${FONTS_DIR}"
echo

bootstrap_echo "If you have a Yubikey available, you may set it up now. If so, please
insert the yubikey before continuing."
echo "Do you want to configure a Yubikey?"
select yn in Yes No; do
    case $yn in
        Yes ) add_yubikey; break;;
        No ) printf "Skipping.\n\n"; break;;
    esac
done


if [[ "${OS}" == "mac" ]]; then
    bootstrap_echo "Setting up macOS Dock icons."
    setup_macos_dock
    printf "\e[92mSuccess!\n\n\e[0m"

    bootstrap_echo "Setting up macOS System preferences."
    setup_macos_preferences
    printf "\e[92mSuccess!\n\n\e[0m"
fi


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

return

#!/usr/bin/env bash
set -eo pipefail

print_welcome_message () {
printf "\e[92m
****************************************************
*  __        __   _                          _     *
*  \ \      / /__| | ___ ___  _ __ ___   ___| |    *
*   \ \ /\ / / _ \ |/ __/ _ \| '_ \` _ \ / _ \ |    *
*    \ V  V /  __/ | (_| (_) | | | | | |  __/_|    *
*     \_/\_/ \___|_|\___\___/|_| |_| |_|\___(_)    *
*                                                  *
****************************************************
\e[0m
This will now bootstrap a development environment for a new computer.
It is idempotent, so you may safely run it as many times as is necessary if
you encounter errors.

This script uses \e[96mbrew cask\e[0m, to install applications. It will fail
if it tries to install a program that has already been installed on the system
via other means; therefore, it is advised to run this process before installing
anything else on your system.

"
}

print_exit_success () {
printf "\e[92m
*****************************************
*   ____                                *
*  / ___| _   _  ___ ___ ___  ___ ___   *
*  \___ \| | | |/ __/ __/ _ \/ __/ __|  *
*   ___) | |_| | (_| (_|  __/\__ \__ \  *
*  |____/ \__,_|\___\___\___||___/___/  *
*                                       *
*****************************************
\e[0m
The following steps will be need to taken separately:

Install applications offline:
* Lightroom
* Cisco AnyConnect
* Deedfinder
* Picasa

System settings:
* Open iterm2 settings -> General -> Preferences and load settings from custom directory: '~/.iterm2/'
"
}

print_exit_warning () {
bootstrap_echo "This program exited with an error. It is idempotent, so you may safely
run it again.
"
}

trap '[ "$?" -eq 0 ] || print_exit_warning' EXIT

wait_for_user() {
    read -r -p "Press enter to continue:"
}

bootstrap_echo() {
    local fmt="$1"; shift
    # shellcheck disable=SC2059
    printf "\e[93m[ Bootstrap]\e[0m $fmt\\n" "$@"
}

echo_successful_install() {
    printf "\n\e[92mSuccess!\e[0m %s installed\n\n" "$1"
}

echo_already_installed() {
    printf "%s is already installed.\n\n" "$1"
}

add_yubikey () {
    printf "Starting ssh-agent\n"
    eval "$(ssh-agent -s)" &>/dev/null
    if [[ ! -f "${HOME}/.ssh/id_rsa_yubikey.pub" ]]; then
        printf "Creating ~/.ssh/id_rsa_yubikey.pub\n\n"
        ssh-add -L | grep "cardno:" > ~/.ssh/id_rsa_yubikey.pub
        chmod 400 ~/.ssh/id_rsa_yubikey.pub
        git remote set-url origin git@github.com:jamescurtin/dotfiles.git
    else
        printf "File already exists: ~/.ssh/id_rsa_yubikey.pub. skipping...\n\n"
    fi
    }


#################################################################################
print_welcome_message

if [[ "$(uname)" == "Darwin" ]]; then
    OS="mac"
elif [[ "$(uname)" == "Linux" ]]; then
    OS="linux"
else
    OS="unsupported"
fi

if [[ ! "${OS}" =~ ^(mac|linux)$ ]]; then
    bootstrap_echo "\e[91mThis script only supports macOS and linux installs. Exiting...\e[0m"
    exit 1
fi

echo
bootstrap_echo "You will need to type your password."
wait_for_user

sudo -v
printf "\e[92mSuccess!\n\e[0m"

# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo
bootstrap_echo "The computer will now attempt to update its software. If an update is
available, it will be installed and \e[38;5;178myou cannot stop the process.\e[0m This may take a while."
wait_for_user

sudo softwareupdate -i -a --restart

bootstrap_echo "\nPreparing to install Homebrew 🍺"
if ! command -v brew &>/dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo_successful_install "Homebrew"
else
    echo_already_installed "Homebrew"
fi

bootstrap_echo "Preparing to install brew packages."
brew bundle
echo

bootstrap_echo "Preparing to install oh-my-zsh"
if [[ "${ZSH}" != *".oh-my-zsh"* ]];then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo_successful_install "oh-my-zsh"
else
    echo_already_installed "oh-my-zsh"
fi

bootstrap_echo "Preparing to install tmux plugin manager"
if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo_successful_install "tmux plugin manager"
else
    echo_already_installed "tmux plugin manager"
fi

bootstrap_echo "Preparing to install powerline terminal status bar"
pip3 install powerline-status
echo


bootstrap_echo "Preparing to install powerline-compatable fonts"

git clone https://github.com/powerline/fonts.git \
    && cd fonts \
    && ./install.sh \
    && cd .. \
    && rm -rf fonts
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

setup_macos_dock () {
    dockutil --no-restart --remove all
    dockutil --no-restart --add "/Applications/Calendar.app"
    dockutil --no-restart --add "/Applications/Messages.app"
    dockutil --no-restart --add "/Applications/Google Chrome.app"
    dockutil --no-restart --add "/Applications/System Preferences.app"
    dockutil --no-restart --add "/Applications/iTerm.app"
    dockutil --no-restart --add "/Applications/Spotify.app"
    dockutil --no-restart --add "/Applications/Sourcetree.app"
    dockutil --no-restart --add "/Applications/Microsoft Word.app"
    dockutil --no-restart --add "/Applications/Microsoft Excel.app"
    dockutil --no-restart --add "/Applications/Slack.app"
    dockutil --no-restart --add "/Applications/Visual Studio Code.app"
    killall Dock
}

setup_macos_preferences() {
    osascript -e 'tell application "System Preferences" to quit'
    # Trackpad: enable tap to click for this user and for the login screen
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool false
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 3
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    # Enable “natural” (Lion-style) scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    sudo defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
    # Follow the keyboard focus while zoomed in
    sudo defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
    # Set 24 hour clock
    defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm:ss'
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # Use column view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
    # Enable highlight hover effect for the grid view of a stack (Dock)
    defaults write com.apple.dock mouse-over-hilite-stack -bool true
    # Enable hotcorners
    defaults write com.apple.dock wvous-tl-corner -int 10
    defaults write com.apple.dock wvous-tl-modifier -int 0
    # Check for software updates daily, not just once per week
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
    # Install System data files & security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
    # Automatically download apps purchased on other Macs
    defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
    # Turn on app auto-update
    defaults write com.apple.commerce AutoUpdate -bool true
    # Prevent Photos from opening automatically when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
    # Dark mode
    sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true
    # Set strict firewall
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 2
}

if [[ "${OS}" == "mac" ]]; then
    bootstrap_echo "Setting up macOS Dock icons."
    setup_macos_dock
    printf "\e[92mSuccess!\n\n\e[0m"
    bootstrap_echo "Setting up macOS System preferences."
    setup_macos_preferences
    printf "\e[92mSuccess!\n\n\e[0m"
fi

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bootstrap_echo "Installing dotfiles."
"${__dir}"/install-profile "${OS}"

bootstrap_echo "Sourcing tmux plugins."
"${HOME}"/.tmux/plugins/tpm/bindings/install_plugins



prompt_local_gitconfig() {
printf "\e[96mEnter your name\n\e[0m"
read -r -p "> " NAME
echo
printf "\e[96mEnter your email\n\e[0m"
read -r -p "> " EMAIL
echo
printf "\e[96mEnter your GPG Signing Key ID\n\e[0m"
read -r -p "> " SIGNING_KEY_ID
echo
printf \
"[user]
    name = %s
    email = %s
    signingkey = %s
" "${NAME}" "${EMAIL}" "${SIGNING_KEY_ID}" > ${HOME}/.git/gitconfig.local
printf "\e[92mSuccess!\n\n\e[0m"
}

configure_local_gitconfig () {
    bootstrap_echo "Configuring local gitconfig options"
    if [[ ! -f "${HOME}/.git/gitconfig.local" ]]; then
        touch "${HOME}/.git/gitconfig.local"
        prompt_local_gitconfig
    else
        echo "Local gitconfig already exists. Do you want to overwrite it?"
        select yn in Yes No; do
            case $yn in
                Yes ) prompt_local_gitconfig; break;;
                No ) printf "Skipping...\n\n"; break;;
            esac
        done
    fi
}

configure_local_gitconfig

print_exit_success

#!/usr/bin/env bash
set -eo pipefail

# shellcheck source=bootstrap/messages.sh
source messages.sh

activate_gpg() {
    printf "Starting ssh-agent\n"
    eval "$(ssh-agent -s)" &> /dev/null
    tty="$(tty)"
    ssh_auth_sock=$(gpgconf --list-dirs agent-ssh-socket)
    export GPG_TTY tty
    export SSH_AUTH_SOCK ssh_auth_sock
    gpgconf --launch gpg-agent
}

add_yubikey() {
    activate_gpg
    mkdir -p "${HOME}"/.ssh
    if [[ ! -f "${HOME}/.ssh/id_rsa_yubikey.pub" ]]; then
        printf "Creating ~/.ssh/id_rsa_yubikey.pub\n\n"
        ssh-add -L | grep "cardno:" > ~/.ssh/id_rsa_yubikey.pub
        chmod 400 ~/.ssh/id_rsa_yubikey.pub
        git remote set-url origin git@github.com:jamescurtin/dotfiles.git
        gpg --list-secret-keys
    else
        printf "File already exists: ~/.ssh/id_rsa_yubikey.pub. skipping...\n\n"
    fi
}

configure_local_gitconfig() {
    bootstrap_echo "Configuring local gitconfig options. This information will be used associated with your git commits."
    if [[ ! -f "${HOME}/.gitconfig.local" ]]; then
        touch "${HOME}/.gitconfig.local"
        prompt_local_gitconfig
    else
        echo "Local gitconfig already exists. Do you want to overwrite it?"
        select yn in Yes No; do
            case $yn in
                Yes)
                    prompt_local_gitconfig
                    break
                    ;;
                No)
                    printf "Skipping...\n\n"
                    break
                    ;;
            esac
        done
    fi
}

configure_gpg_public_keys() {
    bootstrap_echo "Importing GPG public keys"
    curl https://keybase.io/jameswcurtin/pgp_keys.asc | gpg --import
    KEYID=$(curl https://keybase.io/jameswcurtin/pgp_keys.asc | gpg --dry-run --import --import-options show-only --with-colons | awk -F: '/^pub:/ { print $5 }')
}

prompt_local_gitconfig() {
    printf "\e[96mEnter your name\n\e[0m"
    read -r -p "> " NAME
    echo

    printf "\e[96mEnter your email\n\e[0m"
    read -r -p "> " EMAIL
    echo

    printf "\e[96mEnter your GPG Signing Key ID [%s]\n\e[0m" "${KEYID}"
    read -r -p "> " SIGNING_KEY_ID
    echo

    printf "\e[92mPlease check the following before proceeding!\e[0m You entered:\n\e[96mName: \e[0m%s\n\e[96mEmail: \e[0m%s\n\e[96mSigning Key: \e[0m%s\n\n" "${NAME}" "${EMAIL}" "${SIGNING_KEY_ID:-$KEYID}"
    printf "Is this correct?\n"
    select yn in Yes No Abort; do
        case $yn in
            Yes) break ;;
            No)
                prompt_local_gitconfig
                break
                ;;
            Abort)
                echo "Skipping..."
                return
                break
                ;;
        esac
    done

    printf "[user]
    name = %s
    email = %s
    signingkey = %s
" "${NAME}" "${EMAIL}" "${SIGNING_KEY_ID:-$KEYID}" > "${HOME}"/.gitconfig.local

    printf "\e[92mSuccess!\n\n\e[0m"
}

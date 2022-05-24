#!/usr/bin/env bash
set -eo pipefail

print_welcome_message() {
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

print_exit_success() {
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

System settings:
* Open iterm2 settings -> General -> Preferences and load settings from custom directory: '~/.iterm2/'
* TODO: RAYCAST
"
}

print_exit_warning() {
    bootstrap_echo "This program exited with an error. It is idempotent, so you may safely
run it again.
"
}

wait_for_user() {
    read -r -p "Press enter to continue:"
}

bootstrap_echo() {
    local fmt="$1"
    shift
    # shellcheck disable=SC2059
    printf "\e[93m[Bootstrapper]\e[0m $fmt\\n" "$@"
}

echo_install_status() {
    if [[ $2 == 1 ]]; then
        printf "\n\e[92mSuccess!\e[0m %s installed\n\n" "$1"
    else
        printf "%s is already installed.\n\n" "$1"
    fi
}

#!/usr/bin/env bash
set -eo pipefail

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

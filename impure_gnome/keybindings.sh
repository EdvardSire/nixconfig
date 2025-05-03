#!/usr/bin/env bash

# Set the list of custom keybindings
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "[
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/'
]"

dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Terminator'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'terminator'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Super>Return'"

dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name "'Feh'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command "'feh -F'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding "'<Super><Shift>h'"

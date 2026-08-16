#!/usr/bin/env bash

### This is a very impure way of doing it, but i prefer it over indulging in
### home-manager. Here is equivalent nix expression:  
### dconf = {
###   enable = true;
###   settings = {
###     "org/gnome/mutter" = {
###       experimental-features = [ "scale-monitor-framebuffer" ];
###     };
###     "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
###     "org/gnome/desktop/remote-desktop/rdp" = {
###       screen-share-mode = "extend";
###     };
###   };
### };

### on ubuntu e.g. 26.04
### apt install gnome-shell-extension-launch-new-instance
### reboot
### gnome-extensions enable launch-new-instance@gnome-shell-extensions.gcampax.github.com

### previous settings
# dconf write /org/gnome/mutter/workspaces-only-on-primary true
# dconf write /org/gnome/desktop/remote-desktop/rdp/screen-share-mode "'extend'"
#
major=$(
    gdbus call --session \
        --dest org.gnome.Shell \
        --object-path /org/gnome/Shell \
        --method org.freedesktop.DBus.Properties.Get \
        org.gnome.Shell ShellVersion |
    grep -oE '[0-9]+' |
    head -n1
)

[ "${major:-0}" -ge 50 ] || {
    echo "GNOME Shell >= 50 required" >&2
    exit 1
}

dconf write /org/gnome/mutter/experimental-features "['scale-monitor-framebuffer']"
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/show-battery-percentage true
dconf write /org/gnome/desktop/interface/clock-show-seconds true

dconf write /org/gnome/desktop/calendar/show-weekdate true
dconf write /org/gnome/desktop/calendar/week-start-day "'monday'"

# autohide dock/sidebar
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide false
dconf write /org/gnome/shell/extensions/dash-to-dock/autohide true


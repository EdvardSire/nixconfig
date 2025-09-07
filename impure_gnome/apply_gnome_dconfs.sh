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

dconf write /org/gnome/mutter/experimental-features "['scale-monitor-framebuffer']"
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/remote-desktop/rdp/screen-share-mode "'extend'"
dconf write /org/gnome/desktop/interface/show-battery-percentage true
dconf write /org/gnome/mutter/workspaces-only-on-primary true
dconf write /org/gnome/desktop/interface/clock-show-seconds true

dconf write /org/gnome/desktop/calendar/show-weekdate true
#https://github.com/F-i-f/weeks-start-on-monday

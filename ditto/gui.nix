{
  pkgs,
}:
with pkgs;
[
  xournalpp
  thunderbird
  obsidian
  vlc
  eog
  geeqie
  feh
  gparted
  fido2-manage
  bruno
  libreoffice-qt6-still
  qgis-ltr
  element-desktop
  qgroundcontrol
  meld
  signal-desktop
  protonvpn-gui
  dbeaver-bin
  freecad
  camset
  looking-glass-client
  tigervnc
  (octaveFull.withPackages (
    opkgs: with opkgs; [
      control
    ]
  ))
  kdePackages.kcachegrind
  ungoogled-chromium
]

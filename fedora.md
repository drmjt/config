
# Fedora 40

## Disabling auto-suspend in Gnome including in GDM

```
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo dnf in dbus-x11
xhost + local:
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
xhost - local:
```

## Brave / Chromium Hi-DPI scaling issues

Make sure Brave is using the wayland backend, by setting 'Preferred Ozone platform' in ```brave://flags/```

## Installing dependencies for watchman development

General Dependencies
```

sudo dnf install git git-lfs ninja-build patch wget meson make cmake         \
     binutils clang gcc gcc-c++ libasan libtsan libubsan glm-devel           \
     pkgconf-pkg-config mosquitto-devel libconfig-devel                      \
     glslang vulkan-validation-layers vulkan-headers vulkan-tools            \
     sqlite-devel  libwayland-client wayland-protocols-devel                 \
     ncurses-devel gstreamer1 gstreamer1-vaapi                               \
     gstreamer1-plugins-base gstreamer1-plugins-base-devel                   \
     gstreamer1-plugins-good gstreamer1-rtsp-server-devel

```

Dependencies from RPM Fusion (requires EPEL) to enable x264, etc.
```
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf in --allowerasing  gstreamer1-libav gstreamer1-plugins-ugly        \
     gstreamer1-plugins-bad-freeworld ffmpeg-devel mesa-va-drivers-freeworld      
```


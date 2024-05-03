
# Fedora 40

## Disabling auto-suspend including in GDM

```
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo dnf in dbus-x11
xhost + local:
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
xhost - local:
```

## Text editor / C++ IDE

Install Helix with clangd

```
sudo dnf in helix clang-tools-extra
```

Add configuration to the file ```~/.config/helix/config.toml```

```
theme = "github_light"

[editor]
auto-pairs = false
bufferline = "always"
```

## Installing dependencies for watchman development

General Dependencies
```

sudo dnf install git git-lfs ninja-build patch wget meson make cmake         \
     binutils clang gcc gcc-c++ libasan libtsan libubsan glm-devel           \
     pkgconf-pkg-config mosquitto-devel libconfig-devel                      \
     glslang vulkan-validation-layers vulkan-headers vulkan-tools            \
     sqlite-devel  libwayland-client wayland-protocols-devel                 \
     gstreamer1 gstreamer1-vaapi                                             \
     gstreamer1-plugins-base gstreamer1-plugins-base-devel                   \
     gstreamer1-plugins-good gstreamer1-rtsp-server-devel

```

Dependencies from RPM Fusion (requires EPEL) to enable x264, etc.
```
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf in --allowerasing  gstreamer1-libav gstreamer1-plugins-ugly        \
     gstreamer1-plugins-bad-freeworld ffmpeg-devel mesa-va-drivers-freeworld      
```


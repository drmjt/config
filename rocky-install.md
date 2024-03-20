
# Rocky 9.3

## Disabling auto-suspend including in GDM

```
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo dnf in dbus-x11
xhost + local:
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
xhost - local:
```


## Installing dependencies for watchman development

General Dependencies, including from EPEL
```
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release

sudo dnf install git git-lfs ninja-build patch wget meson make cmake         \
     binutils clang gcc gcc-c++ libasan libtsan libubsan glm-devel           \
     pkgconf-pkg-config mosquitto-devel libconfig-devel                      \
     glslang vulkan-validation-layers vulkan-headers vulkan-tools            \
     sqlite-devel  libwayland-client wayland-protocols-devel                 \
     gstreamer1 gstreamer1-vaapi                                             \
     gstreamer1-plugins-base gstreamer1-plugins-base-devel                   \
     gstreamer1-plugins-good gstreamer1-rtsp-server-devel

```


At the time of writing, gstreamer1-rtsp-server-devel is only in the Devel
repository, which is not recommended to keep enabled, but it should be fine
if restricted to needed packages.

```
sudo dnf config-manager --set-enabled devel
sudo vim /etc/yum.repos.d/rocky-devel.repo
```

Add the line: ```includepkgs=gstreamer1-rtsp-server-devel``` to the section [devel]


Additional packages that have reduced functionality compared to versions in RPM Fusion
```
sudo dnf install mesa-dri-drivers gstreamer1-plugins-bad-free                \
     gstreamer1-plugins-ugly-free ffmpeg-free-devel
```

Dependencies from RPM Fusion (requires EPEL) to enable x264, etc.
```
sudo dnf in rpmfusion-free-release

sudo dnf in ffmpeg-devel gstreamer1-libav gstreamer1-plugins-bad-freeworld   \
     gstreamer1-plugins-ugly mesa-dri-drivers
```

Note: The version of gcc and cmake in EL9.3 are too old. Install cmake from source.

```
sudo dnf install gcc-toolset-13
scl enable gcc-toolset-13 bash
gcc --version
```

The package mesa-dri-drivers in EL9 is missing vaapi hardware support. Need to recompile.
Download the source rpm, then:

```
sudo dnf in yum-utils
sudo yum-builddep ./mesa-23.1.4-1.el9.src.rpm
rpm -i ./mesa-23.1.4-1.el9.src.rpm
cd ~/rpmbuild/SPECS
vim mesa.spec
```

Add support for video formats by adding the following arguments
to the %meson command. (Newer versions of mesa support more formats.)

```
-Dvideo-codecs=h264dec,h264enc,h265dec,h265enc,vc1dec \
```

Then build and install:
```
rpmbuild -ba mesa.spec
sudo rpm -i --reinstall ~/rpmbuild/RPMS/x86_64/mesa-dri-drivers-23.1.4-1.el9.x86_64.rpm
```

TODO: Ideally, this package would be renamed mesa-dri-drivers-freeworld,
and would replace the old package using 'dnf swap'.


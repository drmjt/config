
# Rocky 9.3

## Enabling mDNS (.local addresses, including finding wifi printer)

Install the library that provides mdns support, and allow it to pass through the firewall

```
sudo dnf in nss-mdns
sudo systemctl restart NetworkManager
sudo firewall-cmd --permanent --add-service=mdns
sudo systemctl restart firewalld
```

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
theme = "adwaita-dark"

[editor]
auto-pairs = false
bufferline = "always"
```

## Installing dependencies for watchman development

General Dependencies, including from EPEL
```
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release

sudo dnf install git git-lfs ninja-build patch wget meson make               \
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

Note: The version of gcc and cmake in EL9.3 are too old. Extract cmake linux binaries to /opt,
and symbolic link the cmake binary to ```/usr/local/sbin/cmake```

```
sudo dnf install gcc-toolset-13
scl enable gcc-toolset-13 bash
gcc --version
```

For clangd to pick up the newer standard library headers, create a ```.clangd``` file in a
parent/root of the source code folders, containing
```
CompileFlags:                     # Tweak the parse settings
  Add: [ -stdlib++-isystem/opt/rh/gcc-toolset-13/root/usr/include/c++/13, -stdlib++-isystem/opt/rh/gcc-toolset-13/root/usr/include/c++/13/x86_64-redhat-linux ]
```


The package mesa-dri-drivers in EL9 is missing vaapi hardware support. Need to recompile.
Download the source rpm, then:

```
sudo dnf in yum-utils rpm-build
dnf download --source mesa-dri-drivers
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

## Luks encryption

Currently integrity is too slow. Even with the option --integrity-no-journal, writes seeemed to be ~25MB/s.
An example of LUKS parameters:

```
cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --iter-time 5000 --key-size 512 --pbkdf argon2id --use-random --verify-passphrase --sector-size 4096 luksFormat /dev/sda
cryptsetup luksOpen --persistent /dev/sda karak
mkfs.xfs -b size=4096 -m bigtime=1 -L karak -f /dev/mapper/karak
```

## Building from source on Red Hat

```
dnf in rpm-build yum-utils
dnf info gstreamer1-rtsp-server
subscription-manager repos |egrep "rhel-9-for-x86_64-appstream"
subscription-manager repos --enable=rhel-9-for-x86_64-appstream-source-rpms
yumdownloader --source  gstreamer1-rtsp-server
sudo yum-builddep ./gstreamer1-rtsp-server-1.22.1-1.el9.src.rpm
rpm -i ./gstreamer1-rtsp-server-1.22.1-1.el9.src.rpm
cd ~/rpmbuild/SPECS
rpmbuild -ba gstreamer1-rtsp-server.spec
cd ~/rpmbuild/RPMS/x86_64/
sudo rpm -i ./gstreamer1-rtsp-server-1.22.1-1.el9.x86_64.rpm ./gstreamer1-rtsp-server-devel-1.22.1-1.el9.x86_64.rpm
```

# Building Yocto in Podman

To work with selinux, the run command is

```
docker --storage-opt overlay.mount_program=/usr/bin/fuse-overlayfs --storage-opt overlay.mountopt=nodev,metacopy=on,noxattrs=1 run -v ~/podman:/mnt:z -it watch-station/scarthgap:base /bin/bash
```

Note that running as root will put the containers in the root partition, where Rocky might not have provided much space

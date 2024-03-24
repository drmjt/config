
# Ubuntu 24.04

## Opt out of beta testing updates

Create the file 
```
sudo vim /etc/apt/apt.conf.d/99-Phased-Updates
```

And enter the following lines:
```
Update-Manager::Never-Include-Phased-Updates true;
APT::Get::Never-Include-Phased-Updates true;
```

## Disabling auto-suspend including in GDM

```
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo apt install dbus-x11
xhost + local:
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
xhost - local:
```

## Encrypted ZFS

The root pool is create by the installer with the following command.

```
History for 'rpool':
2024-03-22.21:07:06 zpool create -o ashift=12 -o autotrim=on -O canmount=off -O normalization=formD -O acltype=posixacl -O compression=lz4 -O devices=off -O dnodesize=auto -O relatime=on -O sync=standard -O xattr=sa -O encryption=on -O keylocation=file:///tmp/tmpp7696c3m -O keyformat=raw -O mountpoint=/ -R /target rpool /dev/disk/by-id/ata-CIE_MS_M335_128GB_204600000193-part4
2024-03-22.21:07:06 zpool set cachefile=/etc/zfs/zpool.cache rpool
2024-03-22.21:07:06 zfs create -o encryption=off -V 20971520 rpool/keystore
2024-03-22.21:07:14 zfs set keylocation=file:///run/keystore/rpool/system.key rpool
2024-03-22.21:07:14 zfs create -o canmount=off -o mountpoint=none rpool/ROOT
2024-03-22.21:07:14 zfs create -o canmount=on -o mountpoint=/ rpool/ROOT/ubuntu_omybwd
2024-03-22.21:07:14 zfs create -o canmount=off rpool/ROOT/ubuntu_omybwd/var
........
```

These are adjusted for additional encrypted ZFS disks. The files in ```/etc/zfs/zfs-list.cache/``` are created first, so that when any changes are seen to those pools by a daemon, the files are updated.

```
mkdir /etc/zfs/zfs-list.cache
touch /etc/zfs/zfs-list.cache/librarium
touch /etc/zfs/zfs-list.cache/reclusiam

zpool create -o ashift=12 -o autotrim=on -O normalization=formD -O acltype=posixacl -O compression=lz4 -O dnodesize=auto -O relatime=on -O sync=standard -O xattr=sa -O encryption=on -O keylocation=file:///run/keystore/rpool/system.key -O keyformat=raw librarium /dev/disk/by-id/ata-Micron_5100_MTFDDAK1T9TCB_1721174CDF87

zpool create -o ashift=12 -o autotrim=on -O normalization=formD -O acltype=posixacl -O compression=lz4 -O dnodesize=auto -O relatime=on -O sync=standard -O xattr=sa -O encryption=on -O keylocation=file:///run/keystore/rpool/system.key -O keyformat=raw reclusiam /dev/disk/by-id/ata-MTFDDAK3T8TCB_18111BB81335

zfs create librarium/docker

```

Check that the cache files have been updated
```
cat /etc/zfs/zfs-list.cache/librarium
```

## Docker root directory

Create/edit the file '''/etc/docker/daemon.json'''  to add

```
{
  "data-root":"/librarium/docker"
}
```


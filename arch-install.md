# Installing Arch Linux

## Enable wifi during install

```
iwctl
station wlan0 connect <SSID>
```


## Partition the harddisk

```
parted /dev/sda
```

```
mklabel gpt

mkpart ESP fat32 1MiB 500MiB
set 1 boot on
name 1 efi

mkpart primary 500MiB 2500MiB
name 2 boot

mkpart primary 2500MiB 100%
set 3 lvm on
name 3 lvm

print
```


## Set up encryption

These modules should already be loaded: `modprobe dm-crypt && modprobe dm-mod`

```
cryptsetup luksFormat -v -s 512 -h sha512 /dev/sda3
cryptsetup open /dev/sda3 luks_lvm
```


## Create the logical volumes for root and swap

The swap partition must be contiguous.

```
pvcreate /dev/mapper/luks_lvm

vgcreate arch /dev/mapper/luks_lvm

lvcreate -n swap -L 8G -C y arch
lvcreate -n root -l 100%FREE arch
```


## Create the filesystems
```
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.xfs -L root /dev/mapper/arch-root
mkswap /dev/mapper/arch-swap
```

## Mount the new filesystems at /mnt
```
swapon /dev/mapper/arch-swap
swapon -a ; swapon -s
mount /dev/mapper/arch-root /mnt
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```

### Separate home or var disk
```
cryptsetup open /dev/sdb luks_home
mkdir /mnt/home
mount /dev/mapper/luks_home /mnt/home
```
At this point, sort out home (and/or var) contents. Deleting dot-files etc.


### Confirm the filesystems are mounted as expected
```
lsblk -f
```


## Bootstrap the new system
If a btrfs root filesystem was chosen instead of xfs, replace `xfsprogs` with `btrfs-progs`
```
pacstrap /mnt base base-devel efibootmgr vim dialog xfsprogs grub mkinitcpio \
              linux linux-firmware lvm2 --noconfirm

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt
```

## Create the initial RAM disk

Edit the file `/etc/mkinitcpio.conf`, to insert `encrypt lvm2` in the HOOKS line.
They must come after `block`, and before `filesystem`. The HOOKS are executed in order.
Then run
```
mkinitcpio -v -p linux
```

## Install grub
This generates the `/boot/grub/` directory
```
grub-install --efi-directory=/boot/efi
```

We need the UUID of `/dev/sda3` (the `luks_lvm` partition) in `/etc/default/grub`, this can be achieved with
```
ls -l /dev/disk/by-uuid | grep sda3 >> /etc/default/grub
vim /etc/default/grub
```

Add the crypt device for root to the linux cmdline:
```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet resume=/dev/mapper/arch-swap cryptdevice=UUID=<PASTE UUID HERE>:luks_lvm:allow-discards"
```

Now generate the grub config
```
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```

## Unencrypting other disks at boot (home/var)


### Removing unused keys
Other older keys can be removed from the LUKS header with: 
```
cryptsetup luksDump <device>
cryptsetup luksKillSlot <device> <key slot number>
```

### Adding partitions to crypttab
Make sure the *other* encrypted disks included in `crypttab`, and unencrypt them with a keyfile, to avoid typing the passphrase twice.

```
dd if=/dev/random of=/crypto_keyfile.bin bs=512 count=10
chmod 000 /crypto_keyfile.bin
cryptsetup luksAddKey /dev/sdb /crypto_keyfile.bin
ls -l /dev/disk/by-uuid | grep sdb >> /etc/crypttab
vim /etc/crypttab
```
Add the line
```
luks_home UUID=<UUID> /crypto_keyfile.bin discard
```
Consider copying the file `crypto_keyfile.bin` to the encrypted filesystem.


## User configuration

Set the root password, then create a new user. The zsh shell with grml configuration is what is used in the arch install disk at the time of writing.

```
passwd
pacman -S zsh grml-zsh-config vi
usermod -s /etc/zsh root
useradd -m -G wheel -s /bin/zsh mathew
passwd mathew
```

Add wheel to sudoers by uncommenting the line for `%wheel` in the sudoers file, using the command
```
visudo
```


## Locale and keyboard
`localectl` doesn't work in the chroot, but it is easy enough to set the locale manually.
```
vim /etc/locale.gen
```
Uncomment `en_GB.UTF-8`
```
locale-gen
vim /etc/locale.conf
```
Add the line

```
LANG=en_GB.UTF-8
```

Next set the console keyboard map
```
vim /etc/vconsole.conf
``` 
Add the line

```
KEYMAP=uk
```

## Install Desktop environment
Install KDE with network manager

```
pacman -S nm-connection-editor network-manager-applet   \
          plasma plasma-wayland-session dolphin konsole \
          chromium kate okular gwenview
systemctl enable NetworkManager
systemctl enable sddm
```

## Finally reboot

```
exit
umount -R /mnt
reboot
```

## After installation

Set the timezone
```
sudo timedatectl set-timezone 'Europe/London'
```

Install ktorrent (at the time of writing requires geoip for seeing info about the torrent/peers)

```
sudo pacman -S geoip ktorrent
```

# TODO

## DNS setup 

To be able to ping/ssh local hostnames provided by router DNS/DHCP, might need to
remove `[!UNAVAIL=return]` the hosts line of `nssswitch.conf`, or just move dns
nearer the beginning to speed up lookups from router
```
vim /etc/nsswitch.conf
```

```
#hosts: mymachines resolve files myhostname dns
hosts: mymachines dns resolve [!UNAVAIL=return] files myhostname
```



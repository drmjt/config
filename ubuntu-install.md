
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


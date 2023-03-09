# luksman
**A simple manager for LUKS encrypted volumes**\
I made luksman because I wanted a quick and easy way to create, mount and unmount encrypted storage in my Linux workstation. These operations require several arcane commands involving losetup, cryptsetup and filesystem management commands and I was tired to have to read the corresponding man pages everytime I needed a new encrypted volume. 
With luksman I can do everything with a simple command, with some easy to remember options.

Main Repository : https://github.com/rigou/luksman

Prerequisites : apt install cryptsetup-bin

## Features
* you can create / mount / unmount LUKS encrypted volumes with a single command
* you can use a file container or a disk partition to store an encrypted volume
* you can enter a passphrase interactively when creating / opening an encrypted volume, or use a key file
* key files may conveniently reside in a removable usb flash drive, allowing you to take them with you when you do not use your computer
* you can revoke a key file and generate a new one if you think it has been compromised

These operations are all I needed in my use case, so I did not implement anything else to keep things simple. If your requirements are more complex, you can still use cryptsetup on the encrypted volumes and do whatever you want.

## Installation
```
chown root: luksman
chmod 740 luksman
cp luksman /usr/local/sbin
```
*optionally, add this convenient alias :*
```
echo "alias lum='sudo /usr/local/sbin/luksman'" >>$HOME/.bashrc
```
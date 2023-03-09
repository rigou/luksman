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
Download source code of latest release at https://github.com/rigou/luksman/releases
```
tar xzf luksman_vx.y.z.tar.gz
sudo chown root: luksman
sudo chmod 740 luksman
sudo mv luksman /usr/local/sbin
```
*optionally, add this convenient alias :*
```
echo "alias lum='sudo /usr/local/sbin/luksman'" >>$HOME/.bashrc
```
## Synopsis
```
sudo luksman action [volume_name [options]]
```
**Actions :**
* -c create an encrypted volume
* -m mount an encrypted volume
* -u unmount an encrypted volume
* -a add or replace a key file
* -i print volume information
* -l list mounted volumes

**Options :**
* -d path of the block device corresponding to the disk partition where the encrypted volume will be / is located
* -f path of the folder where the file container will be / is located
* -s size of the file container which will be created, in MiB (min size 20 MiB)
* -o logname of the owner of the filesystem which will be created in the encrypted volume
* -k path of the block device corresponding to the disk partition where the key file will be / is located
* -K label of the filesystem where the key file will be / is located


### 1. Create an encrypted volume in a file container or in a disk partition, optionally storing the key in a file:
```
sudo luksman -c name (-f folder -s size_MiB | -d device) [(-k keyfile_device | -K keyfile_disk_label)] -o owner_name
```
**1.1 Example: create a 256 MiB encrypted volume in a file container named MYFILE in the folder /home/guest, prompting user to enter a passphrase :**
```
luksman -c MYFILE -f /home/guest -s 256 -o guest
```
**1.2 Example: create a 256 MiB encrypted volume in a file container named MYFILE, store it in the folder /home/guest, generate a random key and write it in a keyfile located in the usb flash drive at /dev/sdb1 :**
```
luksman -c MYFILE -f /home/guest -s 256 -k /dev/sdb1 -o guest
```
```
luksman -c MYDISK -d /dev/sda3 -o guest
```
```
luksman -c MYDISK -d /dev/sda3 -o guest -K MYKEYS
```

add or replace a key file (a new key file will be created):
luksman -a name (-f folder | -d device) (-k keyfile_device | -K keyfile_disk_label)
luksman -a MYFILE -f /home/guest -k /dev/sdb1
luksman -a MYDISK -d /dev/sda3 -K MYKEYS

mount volume (use option -k or -K to use key file):
luksman -m name (-f folder | -d device) [(-k keyfile_device | -K keyfile_disk_label)]
luksman -m MYFILE -f /home/guest
luksman -m MYDISK -d /dev/sda3 -k /dev/sdb1
luksman -m MYDISK -d /dev/sda3 -K MYKEYS

unmount volume:
luksman -u name
luksman -u MYFILE
luksman -u MYDISK

print volume information:
luksman -i name
luksman -i MYFILE
luksman -i MYDISK

list mounted volumes:
luksman -l

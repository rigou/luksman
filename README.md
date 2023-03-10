# luksman
**A simple manager for LUKS encrypted volumes**\
I made luksman because I wanted a quick and easy way to create, mount and unmount encrypted storage in my Linux workstation. These operations require several arcane commands involving losetup, cryptsetup and filesystem management commands and I was tired to read the corresponding man pages everytime I needed a new encrypted volume. 
With luksman I can do everything with a single command and some easy to remember options.

Main Repository : https://github.com/rigou/luksman

## Features
* you can create / mount / unmount LUKS encrypted volumes with a single command
* you can use a file container or a disk partition to store an encrypted volume
* you can enter a passphrase interactively when creating / opening an encrypted volume, or use a key file
* key files may conveniently reside in a removable usb flash drive, allowing you to take them with you when you do not use your computer
* you can revoke a key file and generate a new one if you think it has been compromised

These operations are all I needed in my use case, so I did not implement anything else to keep things simple. If your requirements are more complex, you can still use cryptsetup on the encrypted volumes and do whatever you want.

## Installation
Install the required package ``cryptsetup-bin``

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
## Usage
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
* -f path of the folder where the file container will be / is located. An absolute path is recommended ; a relative path will be interpreted as relative to your home directory
* -s size of the file container which will be created, in MiB. The minimum size is 17 MiB
* -o logname of the owner of the filesystem which will be created in the encrypted volume
* -k path of the block device corresponding to the disk partition where the key file will be / is located
* -K label of the filesystem where the key file will be / is located

### 1. Create an encrypted volume
```
sudo luksman -c name (-f folder -s size_MiB | -d device) [(-k keyfile_device | -K keyfile_disk_label)] -o owner_name
```
* option -o is required, it specifies the owner of the filesystem
* when using option -d, the current contents of the partition will be lost ; use ``lsblk`` to double-check the device name
* when using option -f, the file container will be created in the specified folder with the given name and the ".dat" extension
* when using option -k or -K, the key file will be created in the "/luksman" folder of the specified device with the given name and the ".key" extension

<details><summary>click here to see some examples</summary>

**Create a 256 MiB encrypted volume in a file container named CLASSIFIED in the folder /home/guest, prompting user for a passphrase :**
```
luksman -c CLASSIFIED -f /home/guest -s 256 -o guest
```
**Create a 256 MiB encrypted volume in a file container named CLASSIFIED, store it in the folder /home/guest, generate a random key and write it in a key file located in the usb flash drive labeled MYKEYS :**
```
luksman -c CLASSIFIED -f /home/guest -s 256 -K MYKEYS -o guest
```
**Create a 256 MiB encrypted volume in a file container named CLASSIFIED, store it in the folder /home/guest, generate a random key and write it in a key file located in the usb flash drive at /dev/sdb1 :**
```
luksman -c CLASSIFIED -f /home/guest -s 256 -k /dev/sdb1 -o guest
```
**Create an encrypted volume in the disk partition /dev/sda3, prompting user for a passphrase :**
```
luksman -c CLASSIFIED -d /dev/sda3 -o guest
```
**Create an encrypted volume in the disk partition /dev/sda3, generate a random key and write it in a key file located in the usb flash drive labeled MYKEYS :**
```
luksman -c CLASSIFIED -d /dev/sda3 -K MYKEYS -o guest
```
**Create an encrypted volume in the disk partition /dev/sda3, generate a random key and write it in a key file located in the usb flash drive at /dev/sdb1 :**
```
luksman -c CLASSIFIED -d /dev/sda3 -k /dev/sdb1 -o guest
```
</details>


### 2. Add or replace a key file
```
luksman -a name (-f folder | -d device) (-k keyfile_device | -K keyfile_disk_label)
```
* use this command to change the key of an encrypted volume
* this command generates a new key and writes it in a key file, the existing key will be revoked and the key file will be replaced
* if the volume was created using a passphrase, a key file will be added and the passphrase will be revoked
* the key file will be created in the "/luksman" folder of the specified device with the given name and the ".key" extension

<details><summary>click here to see some examples</summary>

**Add or replace the key file of the encrypted volume named CLASSIFIED in the folder /home/guest, and write this key file in the usb flash drive labeled MYKEYS :**
```
luksman -a CLASSIFIED -f /home/guest -K MYKEYS
```
**Add or replace the key file of the encrypted volume in the disk partition /dev/sda3, and write this key file in the usb flash drive labeled MYKEYS :**
```
luksman -a CLASSIFIED -d /dev/sda3 -K MYKEYS
```
**Add or replace the key file of the encrypted volume named CLASSIFIED in the folder /home/guest, and write this key file in the usb flash drive at /dev/sdb1 :**
```
luksman -a CLASSIFIED -f /home/guest -k /dev/sdb1
```
**Add or replace the key file of the encrypted volume in the disk partition /dev/sda3, and write this key file in the usb flash drive labeled at /dev/sdb1 :**
```
luksman -a CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 3. Mount an encrypted volume
```
luksman -m name (-f folder | -d device) [(-k keyfile_device | -K keyfile_disk_label)]
```
* if the volume was created using a passphrase, user will be prompted for it
* if there is a key file for this volume in the device specified by option -k or -K, it will be used to mount the encrypted volume automatically
* after mounting the volume, the device specified by option -k or -K is inactive and can be removed
* the mountpoint of volume "name" is /mnt/luksman/name

<details><summary>click here to see some examples</summary>

**Mount the encrypted volume named CLASSIFIED located in the folder /home/guest, prompting user for a passphrase :**
```
luksman -m CLASSIFIED -f /home/guest
```
**Mount the encrypted volume named CLASSIFIED located in the folder /home/guest, using a key file in the usb flash drive labeled MYKEYS :**
```
luksman -m CLASSIFIED -f /home/guest -K MYKEYS
```
**Mount the encrypted volume named CLASSIFIED located in the folder /home/guest, using a key file in the usb flash drive at /dev/sdb1 :**
```
luksman -m CLASSIFIED -f /home/guest -k /dev/sdb1
```
**Mount the encrypted volume located in the disk partition /dev/sda3, prompting user for a passphrase :**
```
luksman -m CLASSIFIED -d /dev/sda3
```
**Mount the encrypted volume located in the disk partition /dev/sda3, using a key file in the usb flash drive labeled MYKEYS :**
```
luksman -m CLASSIFIED -d /dev/sda3 -K MYKEYS
```
**Mount the encrypted volume located in the disk partition /dev/sda3, using a key file in the usb flash drive at /dev/sdb1 :**
```
luksman -m CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 4. Unmount an encrypted volume
```
luksman -u name
```
this command applies to any encrypted volume, either located in a file container or in a disk partition

<details><summary>click here to see an example</summary>

```
luksman -u CLASSIFIED
```
</details>

### 5. Print encrypted volume information
```
luksman -i name
```
this command prints the mount state of given encrypted volume

<details><summary>click here to see an example</summary>

```
luksman -i CLASSIFIED
-> CLASSIFIED is mounted at /mnt/luksman/CLASSIFIED
```
</details>

### 6. List mounted volumes
```
luksman -l
```
this command prints the mountpoints of all currently mounted encrypted volumes

<details><summary>click here to see an example</summary>

```
luksman -l
-> /mnt/luksman/CLASSIFIED
-> /mnt/luksman/CONFIDENTIAL
```
</details>

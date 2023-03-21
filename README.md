# luksman
**A simple manager for encrypted volumes**\
With ``luksman`` you can easily create, mount and unmount encrypted storage in your GNU/Linux computer. These operations would normally require several arcane commands involving losetup, cryptsetup and filesystem management but with ``luksman`` you can can do all this with a single command and some easy to remember options.

Main Repository : https://github.com/rigou/luksman

*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.*

## Features
* you can create / mount / unmount LUKS encrypted volumes with a single command
* you can use a container file or a disk partition to store an encrypted volume
* you can enter a passphrase interactively when creating / opening an encrypted volume, or use a key file
* key files may conveniently reside in a removable flash drive, allowing you to take them with you when you leave your computer unattended
* you can revoke a key file and generate a new one if you think it has been compromised
* you can delete an encrypted volume and its key file

These features cover 99% of the author's needs. If your requirements are more complex, you can still use [cryptsetup](https://wiki.archlinux.org/title/dm-crypt/Device_encryption) on the encrypted volumes created by ``luksman`` and do whatever you want.

## Installation
Install the required package ``cryptsetup-bin``
```bash
sudo apt update
sudo apt install cryptsetup-bin
```
Download the latest release of luksman at https://github.com/rigou/luksman/releases
```
tar xzf luksman_vx.y.z.tar.gz
sudo chown root: luksman
sudo chmod 770 luksman
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
* create : create an encrypted volume
* newkey : add or replace a key file
* mount : mount an encrypted volume
* unmount : unmount encrypted volume(s)
* delete : delete an encrypted volume and its key file
* info : print volume information
* list : list mounted volumes

**Volume name :**
* this name uniquely identifies an encrypted volume. The key file (if any) and the container file (if any) are named after it. 
* for ease of use avoid spaces in this name and do not use common illegal characters or symbols for file names : / (forward slash), < (less than), > (greater than), : (colon), " (double quote), \ (backslash), | (vertical bar or pipe), ? (question mark), * (asterisk).

**Options :**
* -d path of the disk partition where the encrypted volume is (or will be) located
* -f path of the folder where the container file is (or will be) located. An absolute path is recommended ; a relative path will be interpreted as relative to your home directory. Options -d and -f are mutually exclusive.
* -s size of the container file which will be created, in MB (1024x1024). The minimum size is 17 MB. Does not apply to volumes backed by a disk partition.
* -o logname of the owner of the filesystem which will be created in the encrypted volume
* -k path of the disk partition where the key file is (or will be) located
* -l label of the filesystem where the key file is (or will be) located

### 1. Create an encrypted volume
```
sudo luksman create name (-f folder -s size_MB | -d device) [(-k keyfile_device | -l keyfile_disk_label)] -o owner_name
```
* option -o is required, it specifies the owner of the filesystem
* when using option -d, the current contents of the partition will be lost ; use ``lsblk`` to double-check the device name
* when using option -f, the container file will be created in the specified folder with the given name and the ".dat" extension
* when using option -k or -l, the key file will be created in the "/luksman" folder of the specified device with the given name and the ".key" extension

<details><summary>click here to see some examples</summary>

**Create a 128 MB encrypted volume in a container file named CLASSIFIED in the folder /home/scott, prompting user for a passphrase :**
```
luksman create CLASSIFIED -f /home/scott -s 128 -o scott
```
**Create a 128 MB encrypted volume in a container file named CLASSIFIED, store it in the folder /home/scott, generate a random key and write it in a key file located in the flash drive labeled MYKEYS :**
```
luksman create CLASSIFIED -f /home/scott -s 128 -l MYKEYS -o scott
```
**Create a 128 MB encrypted volume in a container file named CLASSIFIED, store it in the folder /home/scott, generate a random key and write it in a key file located in the flash drive at /dev/sdb1 :**
```
luksman create CLASSIFIED -f /home/scott -s 128 -k /dev/sdb1 -o scott
```
**Create an encrypted volume in the disk partition /dev/sda3, prompting user for a passphrase :**
```
luksman create CLASSIFIED -d /dev/sda3 -o scott
```
**Create an encrypted volume in the disk partition /dev/sda3, generate a random key and write it in a key file located in the flash drive labeled MYKEYS :**
```
luksman create CLASSIFIED -d /dev/sda3 -l MYKEYS -o scott
```
**Create an encrypted volume in the disk partition /dev/sda3, generate a random key and write it in a key file located in the flash drive at /dev/sdb1 :**
```
luksman create CLASSIFIED -d /dev/sda3 -k /dev/sdb1 -o scott
```
</details>


### 2. Add or replace a key file
```
luksman newkey name (-f folder | -d device) (-k keyfile_device | -l keyfile_disk_label)
```
* use this command to change the key of an encrypted volume
* this command generates a new key and writes it in a key file, the existing key will be revoked and the key file will be replaced
* if the volume was created using a passphrase, a key file will be added and the passphrase will be revoked
* the key file will be created in the "/luksman" folder of the specified device with the given name and the ".key" extension

<details><summary>click here to see some examples</summary>

**Add or replace the key file of the encrypted volume named CLASSIFIED in the folder /home/scott, and write this key file in the flash drive labeled MYKEYS :**
```
luksman newkey CLASSIFIED -f /home/scott -l MYKEYS
```
**Add or replace the key file of the encrypted volume in the disk partition /dev/sda3, and write this key file in the flash drive labeled MYKEYS :**
```
luksman newkey CLASSIFIED -d /dev/sda3 -l MYKEYS
```
**Add or replace the key file of the encrypted volume named CLASSIFIED in the folder /home/scott, and write this key file in the flash drive at /dev/sdb1 :**
```
luksman newkey CLASSIFIED -f /home/scott -k /dev/sdb1
```
**Add or replace the key file of the encrypted volume in the disk partition /dev/sda3, and write this key file in the flash drive labeled at /dev/sdb1 :**
```
luksman newkey CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 3. Mount an encrypted volume
```
luksman mount name (-f folder | -d device) [(-k keyfile_device | -l keyfile_disk_label)]
```
* if the volume was created using a passphrase, user will be prompted for it
* if there is a key file for this volume in the device specified by option -k or -l, it will be used to mount the encrypted volume automatically
* after mounting the volume, the device specified by option -k or -l is inactive and can be removed
* the mountpoint of volume "name" is /mnt/luksman/name

<details><summary>click here to see some examples</summary>

**Mount the encrypted volume named CLASSIFIED located in the folder /home/scott, prompting user for a passphrase :**
```
luksman mount CLASSIFIED -f /home/scott
```
**Mount the encrypted volume named CLASSIFIED located in the folder /home/scott, using a key file in the flash drive labeled MYKEYS :**
```
luksman mount CLASSIFIED -f /home/scott -l MYKEYS
```
**Mount the encrypted volume named CLASSIFIED located in the folder /home/scott, using a key file in the flash drive at /dev/sdb1 :**
```
luksman mount CLASSIFIED -f /home/scott -k /dev/sdb1
```
**Mount the encrypted volume located in the disk partition /dev/sda3, prompting user for a passphrase :**
```
luksman mount CLASSIFIED -d /dev/sda3
```
**Mount the encrypted volume located in the disk partition /dev/sda3, using a key file in the flash drive labeled MYKEYS :**
```
luksman mount CLASSIFIED -d /dev/sda3 -l MYKEYS
```
**Mount the encrypted volume located in the disk partition /dev/sda3, using a key file in the flash drive at /dev/sdb1 :**
```
luksman mount CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 4. Unmount encrypted volume(s)
```
luksman unmount (name | all)
```
* this command applies to any encrypted volume, either located in a container file or in a disk partition
* use argument "all" to unmount all volumes that are currently mounted

<details><summary>click here to see some examples</summary>

**Unmount the encrypted volume named "CLASSIFIED" :**
```
luksman unmount CLASSIFIED
```
**Unmount all encrypted volumes that are currently mounted :**
```
luksman unmount all
```
</details>

### 5. Delete an encrypted volume
```
luksman delete name (-f folder | -d device) [(-k keyfile_device | -l keyfile_disk_label)]
```
* WARNING: This operation is irreversible
* if no key file is specified by option -k or -l, user will be prompted for a passphrase
* the LUKS header of the encrypted volume will be overwritten with random characters, making it permanently inaccessible
* if the encrypted volume resides in a container file, this file will be deleted
* if there is a key file for this volume in the device specified by option -k or -l, this file will be deleted

<details><summary>click here to see some examples</summary>

**Delete the encrypted volume named CLASSIFIED located in the folder /home/scott, prompting user for a passphrase :**
```
luksman delete CLASSIFIED -f /home/scott
```
**Delete the encrypted volume named CLASSIFIED located in the folder /home/scott, and the key file in the flash drive labeled MYKEYS :**
```
luksman delete CLASSIFIED -f /home/scott -l MYKEYS
```
**Delete the encrypted volume named CLASSIFIED located in the folder /home/scott, and the key file in the flash drive at /dev/sdb1 :**
```
luksman delete CLASSIFIED -f /home/scott -k /dev/sdb1
```
**Delete the encrypted volume located in the disk partition /dev/sda3, prompting user for a passphrase :**
```
luksman delete CLASSIFIED -d /dev/sda3
```
**Delete the encrypted volume located in the disk partition /dev/sda3, and the key file in the flash drive labeled MYKEYS :**
```
luksman delete CLASSIFIED -d /dev/sda3 -l MYKEYS
```
**Delete the encrypted volume located in the disk partition /dev/sda3, and the key file in the flash drive at /dev/sdb1 :**
```
luksman delete CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 6. Print encrypted volume information
```
luksman info name
```
this command prints the mount state of given encrypted volume

<details><summary>click here to see an example</summary>

```
luksman info CLASSIFIED
-> CLASSIFIED is mounted at /mnt/luksman/CLASSIFIED
```
</details>

### 7. List mounted volumes
```
luksman list
```
this command prints the mountpoints of all currently mounted encrypted volumes

<details><summary>click here to see an example</summary>

```
luksman list
-> /mnt/luksman/CLASSIFIED
-> /mnt/luksman/CONFIDENTIAL
```
</details>

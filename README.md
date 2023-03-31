# luksman
**A simple manager for encrypted volumes**\
With ``luksman`` you can easily create, mount and unmount encrypted storage in your GNU/Linux computer. These operations would normally require several arcane commands involving losetup, cryptsetup and filesystem management but with ``luksman`` you can can do all this with a single command and a couple of options.

Main Repository : https://github.com/rigou/luksman

*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.*

## Features
* you can create / mount / unmount LUKS encrypted volumes with a single command
* you can use a container file or a disk to store an encrypted volume
* you can enter a passphrase interactively when creating / opening an encrypted volume, or use a key file
* key files may conveniently reside in a removable flash drive, allowing you to take them with you when you leave your computer unattended
* you can revoke a key file and generate a new one if you suspect it has been compromised
* you can delete an encrypted volume and its key file

These features cover 99% of the author's needs. If your requirements are more complex, you can still use [cryptsetup](https://wiki.archlinux.org/title/dm-crypt/Device_encryption) on the encrypted volumes created by ``luksman`` and do whatever you want.

## Installation
Install the required package ``cryptsetup-bin`` for LUKS and dm-crypt support
```console
sudo apt update
sudo apt install cryptsetup-bin
```
Download the latest release of luksman at https://github.com/rigou/luksman/releases
```console
tar xzf luksman-vx.y.z.tar.gz
sudo chown root: luksman
sudo chmod 770 luksman
sudo mv luksman /usr/local/sbin
```
*optionally, add this convenient alias :*
```console
echo "alias lum='sudo /usr/local/sbin/luksman'" >>$HOME/.bashrc
```
## Usage
```console
sudo luksman action [volume_name [options]]
```
**Actions :**
* **create** : create an encrypted volume
* **newkey** : add or replace a key file
* **mount** : mount an encrypted volume
* **unmount** : unmount encrypted volume(s)
* **delete** : delete an encrypted volume and its key file
* **list** : list mounted volumes

**Volume name :**
* this name uniquely identifies an encrypted volume. The key file (if any) and the container file (if any) are named after it
* the valid characters for a volume name are: letters A-Z (both uppercase and lowercase), numbers 0-9, "@", "-", "_"

**Options :**
* **-d** location (device path in /dev or UUID) of the disk (or flash drive, or SD card) where the encrypted volume is (or will be) located. UUID is prefered because device path may change unexpectedly. List UUIDs with ``lsblk -o NAME,RM,UUID``
* **-f** path of the folder where the container file is (or will be) located. An absolute path is recommended ; a relative path will be interpreted as relative to your home directory. Options -d and -f are mutually exclusive
* **-s** size of the container file which will be created, in MB (1024x1024). Applies only to volumes created with option -f . The minimum size is 17 MB
* **-k** location (device path in /dev, UUID or label) of the disk (or flash drive, or SD card) where the key file is (or will be) located. Label or UUID are prefered because device path may change unexpectedly. List labels and UUIDs with ``lsblk -o NAME,RM,LABEL,UUID`` . The valid characters of a label are the same as a volume name (see above)
* **-y** do not ask user to confirm actions which may result in existing data loss

### 1. Create an encrypted volume
```console
sudo luksman create name (-d device | -f folder -s size_MB) [-k keyfile] [-y]
```
* WARNING: when using option -d, the data currently stored at this location will be lost ; use ``lsblk`` to make certain it is correct
* when using option -f, the container file will be created in the specified folder with the given name and the ".dat" extension
* when using option -k the key file will be created in the "/luksman" folder of the specified device with the given name and the ".key" extension

<details><summary>click here to see some examples</summary>

**Create a 128 MB encrypted volume in a container file named CLASSIFIED in the folder /home/scott, prompting user for a passphrase :**
```console
luksman create CLASSIFIED -f /home/scott -s 128
```
**Create a 128 MB encrypted volume in a container file named CLASSIFIED, store it in the folder /home/scott, generate a random key and write it in a key file located in the flash drive labeled MY-KEYS :**
```console
luksman create CLASSIFIED -f /home/scott -s 128 -k MY-KEYS
```
**Create a 128 MB encrypted volume in a container file named CLASSIFIED, store it in the folder /home/scott, generate a random key and write it in a key file located in the flash drive at /dev/sdb1 :**
```console
luksman create CLASSIFIED -f /home/scott -s 128 -k /dev/sdb1
```
**Create an encrypted volume in the disk /dev/sda3, prompting user for a passphrase :**
```console
luksman create CLASSIFIED -d /dev/sda3
```
**Create an encrypted volume in the disk /dev/sda3, generate a random key and write it in a key file located in the flash drive labeled MY-KEYS :**
```console
luksman create CLASSIFIED -d /dev/sda3 -k MY-KEYS
```
**Create an encrypted volume in the disk /dev/sda3, generate a random key and write it in a key file located in the flash drive at /dev/sdb1 :**
```console
luksman create CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>


### 2. Add or replace a key file
```console
luksman newkey name (-d device | -f folder) -k keyfile
```
* use this command to change the key of an encrypted volume
* this command generates a new key and writes it in a key file, the existing key will be revoked and the key file will be replaced
* if the volume was created using a passphrase, a key file will be added and the passphrase will be revoked
* the key file will be created in the "/luksman" folder of the specified device with the given name and the ".key" extension

<details><summary>click here to see some examples</summary>

**Add or replace the key file of the encrypted volume named CLASSIFIED in the folder /home/scott, and write this key file in the flash drive labeled MY-KEYS :**
```console
luksman newkey CLASSIFIED -f /home/scott -k MY-KEYS
```
**Add or replace the key file of the encrypted volume in the disk /dev/sda3, and write this key file in the flash drive labeled MY-KEYS :**
```console
luksman newkey CLASSIFIED -d /dev/sda3 -k MY-KEYS
```
**Add or replace the key file of the encrypted volume named CLASSIFIED in the folder /home/scott, and write this key file in the flash drive at /dev/sdb1 :**
```console
luksman newkey CLASSIFIED -f /home/scott -k /dev/sdb1
```
**Add or replace the key file of the encrypted volume in the disk /dev/sda3, and write this key file in the flash drive labeled at /dev/sdb1 :**
```console
luksman newkey CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 3. Mount an encrypted volume
```console
luksman mount name (-d device | -f folder) [-k keyfile]
```
* if the volume was created using a passphrase, user will be prompted for it
* if there is a key file for this volume in the device specified by option -k, it will be used to mount the encrypted volume automatically
* after mounting the volume, the device specified by option -k is inactive and can be removed
* the mountpoint of volume "name" is /mnt/luksman/name

<details><summary>click here to see some examples</summary>

**Mount the encrypted volume named CLASSIFIED located in the folder /home/scott, prompting user for a passphrase :**
```console
luksman mount CLASSIFIED -f /home/scott
```
**Mount the encrypted volume named CLASSIFIED located in the folder /home/scott, using a key file in the flash drive labeled MY-KEYS :**
```console
luksman mount CLASSIFIED -f /home/scott -k MY-KEYS
```
**Mount the encrypted volume named CLASSIFIED located in the folder /home/scott, using a key file in the flash drive at /dev/sdb1 :**
```console
luksman mount CLASSIFIED -f /home/scott -k /dev/sdb1
```
**Mount the encrypted volume located in the disk /dev/sda3, prompting user for a passphrase :**
```console
luksman mount CLASSIFIED -d /dev/sda3
```
**Mount the encrypted volume located in the disk /dev/sda3, using a key file in the flash drive labeled MY-KEYS :**
```console
luksman mount CLASSIFIED -d /dev/sda3 -k MY-KEYS
```
**Mount the encrypted volume located in the disk /dev/sda3, using a key file in the flash drive at /dev/sdb1 :**
```console
luksman mount CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 4. Unmount encrypted volume(s)
```console
luksman unmount (name | all)
```
* this command applies to any encrypted volume, either located in a container file or in a disk
* use argument "all" to unmount all volumes that are currently mounted

<details><summary>click here to see some examples</summary>

**Unmount the encrypted volume named "CLASSIFIED" :**
```console
luksman unmount CLASSIFIED
```
**Unmount all encrypted volumes that are currently mounted :**
```console
luksman unmount all
```
</details>

### 5. Delete an encrypted volume
```console
luksman delete name (-d device | -f folder) [-k keyfile] [-y]
```
* WARNING: This operation is irreversible
* if no key file is specified by option -k, user will be prompted for a passphrase
* the LUKS header of the encrypted volume will be overwritten with random characters, making it permanently inaccessible
* if the encrypted volume resides in a container file, this file will be deleted
* if there is a key file for this volume in the device specified by option -k, this file will be deleted

<details><summary>click here to see some examples</summary>

**Delete the encrypted volume named CLASSIFIED located in the folder /home/scott, prompting user for a passphrase :**
```console
luksman delete CLASSIFIED -f /home/scott
```
**Delete the encrypted volume named CLASSIFIED located in the folder /home/scott, and the key file in the flash drive labeled MY-KEYS :**
```console
luksman delete CLASSIFIED -f /home/scott -k MY-KEYS
```
**Delete the encrypted volume named CLASSIFIED located in the folder /home/scott, and the key file in the flash drive at /dev/sdb1 :**
```console
luksman delete CLASSIFIED -f /home/scott -k /dev/sdb1
```
**Delete the encrypted volume located in the disk /dev/sda3, prompting user for a passphrase :**
```console
luksman delete CLASSIFIED -d /dev/sda3
```
**Delete the encrypted volume located in the disk /dev/sda3, and the key file in the flash drive labeled MY-KEYS :**
```console
luksman delete CLASSIFIED -d /dev/sda3 -k MY-KEYS
```
**Delete the encrypted volume located in the disk /dev/sda3, and the key file in the flash drive at /dev/sdb1 :**
```console
luksman delete CLASSIFIED -d /dev/sda3 -k /dev/sdb1
```
</details>

### 6. List mounted volumes
```console
luksman list
```
this command prints the location and the mountpoint of each currently mounted encrypted volumes

<details><summary>click here to see an example</summary>

```console
luksman list
> CLASSIFIED    /dev/sda3   /mnt/luksman/CLASSIFIED
> CONFIDENTIAL  /dev/sda4   /mnt/luksman/CONFIDENTIAL
> PRIVATE       /home/scott/PRIVATE.dat    /mnt/luksman/PRIVATE
```
</details>

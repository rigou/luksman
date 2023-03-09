# luksman, a simple manager for Luks encrypted volumes 

Main Repository : https://github.com/rigou/luksman

Prerequisites : apt install cryptsetup-bin

## Installation:
```
chown root: luksman
chmod 740 luksman
cp luksman /usr/local/sbin
```
*optionally, add this convenient alias :*
```
echo "alias lum='sudo /usr/local/sbin/luksman'" >>$HOME/.bashrc
```
#!/bin/bash
# This script is part of the luksman test suite, see https://github.com/rigou/luksman

# you can interrupt this script with this command: touch $HOME/test/STOP
# it will make a clean exit, not leaving any file open

# adjust the devices information below before running this script :
readonly BlockDev='/dev/sdc1' # scratch crypted volume *** ITS CURRENT CONTENTS WILL BE LOST ***
readonly KeyDev='/dev/sdb1' # key files flash drive
readonly KeyUUID='656E-774B'
readonly KeyLabel='LUKSMAN-DEV'

readonly HOMEDIR="/home/${SUDO_USER:-$USER}"
readonly LocalDir="$HOMEDIR/test"

function exit_error {
	echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') (pid=$$) FAILED"
	exit 1
}

#-----------------
# BEGIN
#-----------------

if [ "$(id -u)" != '0' ] ; then
	echo "$(basename "$0") must run as root, run it with sudo $APPNAME"
	exit 1
fi

declare confirmed=''
lsblk -o NAME,SIZE,RM,MOUNTPOINT,LABEL,UUID
read -r -p "Contents of disk $BlockDev will be lost, are you sure (type yes in capital letters) ? " confirmed
if [ "$confirmed" != 'YES' ] ; then
    echo "cancelled"
    exit 1
fi

echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') (pid=$$) BEGIN"
cd "$HOMEDIR/bin" || exit_error
rm -f "$LocalDir/STOP"

# verify that the key drive is available
declare tmp_mount ; tmp_mount="/tmp/$(basename "$0" '.sh')-mount-$$.tmp"
mkdir -p "$tmp_mount"
if ! mount -L $KeyLabel "$tmp_mount" ; then
    echo "key drive $KeyLabel not found"
    exit_error
else
    umount "$tmp_mount"
    rmdir "$tmp_mount"
fi
mkdir -p "$LocalDir"

if ! ./testluksman_param.sh "TEST01" -f "$LocalDir" -k "$KeyDev" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi
if ! ./testluksman_param.sh "TEST02" -f "$LocalDir" -k "$KeyLabel" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi
if ! ./testluksman_param.sh "TEST03" -f "$LocalDir" -k "$KeyUUID" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi

if ! ./testluksman_param.sh "TEST11" -d "$BlockDev" -k "$KeyDev" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi
if ! ./testluksman_param.sh "TEST12" -d "$BlockDev" -k "$KeyLabel" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi
if ! ./testluksman_param.sh "TEST13" -d "$BlockDev" -k "$KeyUUID" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi

if ! ./testluksman_param.sh "TEST21" -UUID "$BlockDev" -k "$KeyDev" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi
if ! ./testluksman_param.sh "TEST22" -UUID "$BlockDev" -k "$KeyLabel" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi
if ! ./testluksman_param.sh "TEST23" -UUID "$BlockDev" -k "$KeyUUID" ; then
    exit_error
fi
if [ -f "$LocalDir/STOP" ] ; then
    exit 0
fi

echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') (pid=$$) SUCCESS"
exit 0

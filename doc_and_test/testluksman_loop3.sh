#!/bin/bash

readonly BlockDev='/dev/sdc1'
readonly KeyDev='/dev/sdb1'
readonly KeyLabel='LUKSMANDEV'
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

# run test until you issue this command: touch $HOME/test/STOP
declare -i iteration=0
while ! [ -f "$LocalDir/STOP" ] ; do
    iteration+=1
    echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') iteration $iteration BEGIN"
    if ! ./testluksman_param.sh "TEST03" -d "$BlockDev" -k "$KeyDev" ; then
        exit_error
    fi
    echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') iteration $iteration END"
    sleep $((RANDOM % 10 + 1))
done

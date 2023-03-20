#!/bin/bash
# to exit the loop cleanly : touch $HOME/test/STOP

# readonly BlockDev='/dev/sdc1'
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

echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') (pid=$$) BEGIN"
cd "$HOMEDIR/bin" || exit_error

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

while ! [ -f "$LocalDir/STOP" ] ; do
    if ! ./testluksman_param.sh "TEST01" -f "$LocalDir" -k "$KeyDev" ; then
        exit_error
    fi
    sleep $((RANDOM % 10 + 1))
done

echo "found $LocalDir/STOP"
echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') (pid=$$) END"

#!/bin/bash

readonly LocalDir='/home/rigou/test'
readonly BlockDev='/dev/sdc1'
readonly KeyDev='/dev/sdb1'
readonly KeyLabel='LUKSMANKEY'

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
cd "/home/${SUDO_USER:-$USER}/bin" || exit_error

while : ; do
    if ! ./testluksman_param.sh "TEST03-$$" -d "$BlockDev" -k "$KeyDev" ; then
        exit_error
    fi
    sleep $((RANDOM % 10 + 1))
done

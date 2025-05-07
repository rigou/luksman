#!/bin/bash
# This script is part of the luksman test suite, see https://github.com/rigou/luksman
# 
# testluksman_loop1.sh, testluksman_loop2.sh and testluksman_loop3.sh are used for testing luksman behaviour under heavy system load
# run them each in a different terminal. They will run indefinitely unless an error occurs.
# you can stop the test at any moment by creating a STOP file in LocalDir : touch $HOMEDIR/test/STOP
# 
# Do not run testluksman.sh while this script is running
#
# This program has been published by its original author in April 2023
# under the GNU General Public License. This program is free software and
# you can redistribute it and/or modify it under the terms of the GNU General 
# Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.
# See the GNU General Public License for more details : https://www.gnu.org/licenses/#GPL 

# cd ~/bin && sudo ./testluksman_loop1.sh 2>&1 |tee testluksman_loops_log/testluksman_loop1_$(date '+%Y%m%dT%H%M').log

# testluksman_loop1.sh : adjust the path and the label of the key files flash drive before running this script
readonly KeyDev='/dev/sdb1'
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
    if ! ./testluksman_param.sh "TEST01" -f "$LocalDir" -k "$KeyDev" ; then
        exit_error
    fi
    echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') iteration $iteration END"
    sleep $((RANDOM % 10 + 1))
done

#!/bin/bash

readonly KeyDev='/dev/sdb1'
readonly KeyLabel='LUKSMANKEY'
readonly KeyMountPoint="/tmp/$(basename $0)"
readonly BlockDev='/dev/sdc1'
readonly User='rigou'

if [ $# -ne 1 ] || [ "${1:0:1}" = '-' ] ; then
	echo "usage: $(basename $0) volume_name"
	echo "key=$KeyDev blockdevice=$BlockDev"
	exit 1
fi

declare Name=$1
declare Dname="D$Name"

declare info Exitval=0

cd /home/rigou/bin
mkdir -p "$KeyMountPoint"

function print_line {
	echo '--------------------------------------------------'
}

function is_blockdev_ready {
	local -i retval_int=1 # error
	
	local -i mounted_bool=$(mount |grep -c $BlockDev)
	local -i found_in_bylabel_bool=$(ls -l /dev/disk/by-label |grep -c $(basename $BlockDev))
	local -i found_in_bypartlabel_bool=$(ls -l /dev/disk/by-partlabel |grep -c $(basename $BlockDev))
	
	if [ $mounted_bool -eq 0 ] && [ $found_in_bylabel_bool -eq 0 ] && [ $found_in_bypartlabel_bool -eq 0 ] ; then
		retval_int=0 # success
	fi
	return $retval_int
}

function is_key_ready {
	local -i retval_int=1
	if mount $KeyDev $KeyMountPoint ; then
		if [ -d $KeyMountPoint/luksman ] ; then
			retval_int=0
		fi
		umount $KeyDev
	fi
	return $retval_int
}

function delete_keys {
	if mount $KeyDev $KeyMountPoint ; then
		rm -f $KeyMountPoint/luksman/$Dname.key
		umount $KeyDev
	fi
}

function exit_error {
	echo "TEST FAILED"
	exit 1
}

if ! is_key_ready ; then
	echo "insert key in $KeyDev"
	exit 1
fi

if ! is_blockdev_ready ; then
	echo "WARNING : $BlockDev appears to be in use, its contents will be lost"
	echo "Enter OK to continue ..."
	input_str='' ; read input_str
	if [ "$input_str" != 'OK' ] ; then
		exit 1
	fi
fi

delete_keys

print_line
echo "VOLUME $Dname IN BLOCK DEVICE $BlockDev"
print_line
./luksman create $Dname -d $BlockDev -o $User
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
echo "TEST WITH PASSPHRASE"
print_line
./luksman mount $Dname -d $BlockDev 
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman umount $Dname
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
echo "TEST WITH KEY"
print_line
./luksman newkey $Dname -d $BlockDev -k $KeyDev
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman mount $Dname -d $BlockDev -k $KeyDev
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman umount $Dname
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman newkey $Dname -d $BlockDev -K $KeyLabel
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman mount $Dname -d $BlockDev -K $KeyLabel
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman umount $Dname
if [ $? -ne 0 ] ; then exit_error ; fi
print_line

delete_keys

echo 'TEST SUCCESS'
exit 0

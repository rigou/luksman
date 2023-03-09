#!/bin/bash
# 2023-03-09

readonly LocalDir='/home/rigou'
readonly KeyDev='/dev/sdb1'
readonly KeyLabel='LUKSMANKEY'
readonly KeyMountPoint="/tmp/$(basename $0)"
readonly User='rigou'

if [ $# -ne 1 ] || [ "${1:0:1}" = '-' ] ; then
	echo "usage: $(basename $0) volume_name"
	echo "key=$KeyDev label=$KeyLabel"
	exit 1
fi

declare Name=$1
declare Fname="F$Name"

declare -i Exitval=0

cd /home/rigou/bin
mkdir -p "$KeyMountPoint"

function print_line {
	echo '--------------------------------------------------'
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
		rm -f $KeyMountPoint/luksman/$Fname.key
		umount $KeyDev
	fi
}

function delete_blockfile {
	rm -f $LocalDir/$Fname.dat
}

function exit_error {
	echo "TEST FAILED"
	exit 1
}

if ! is_key_ready ; then
	echo "insert key in $KeyDev"
	exit 1
fi

delete_blockfile
delete_keys

print_line
echo "VOLUME $Fname IN FILE $LocalDir/$Fname.dat"
print_line
./luksman -c $Fname -f $LocalDir -s 40 -o $User
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
echo "TEST WITH PASSWORD"
print_line
./luksman -m $Fname -f $LocalDir 
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman -u $Fname -f $LocalDir
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
echo "TEST WITH KEY"
print_line
./luksman -a $Fname -f $LocalDir -k $KeyDev
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman -m $Fname -f $LocalDir -k $KeyDev
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman -u $Fname
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman -a $Fname -f $LocalDir -K $KeyLabel
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman -m $Fname -f $LocalDir -K $KeyLabel
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
./luksman -u $Fname
if [ $? -ne 0 ] ; then exit_error ; fi
print_line
echo
print_line

delete_blockfile
delete_keys

echo 'TEST SUCCESS'
exit 0

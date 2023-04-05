#!/bin/bash
# This script is part of the luksman test suite, see https://github.com/rigou/luksman
# it is a subprogram and should not be called from the command line
#
# This program has been published by its original author in April 2023
# under the GNU General Public License. This program is free software and
# you can redistribute it and/or modify it under the terms of the GNU General 
# Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.
# See the GNU General Public License for more details : https://www.gnu.org/licenses/#GPL 

if [ $# -ne 5 ] ; then
	echo "usage: $(basename "$0") volume_name vol_option(-d -f -UUID) vol_path key_option(-k) key_path"
	exit 1
fi

function print_line {
	echo '--------------------------------------------------------------------------------'
}

function exit_error {
	echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) FAILED"
	exit 1
}


function create_sample_text_file {
    local -i kcount=0
    local path=$1
    rm -f "$path"
    while [ $kcount -lt 100 ] ; do
        LC_ALL=C tr -dc '[:alnum:]_\+\-*=,?;.:/!$&#{[|`]}@%&$"~^' < /dev/urandom | head -c 999 >>"$path"
        echo >>"$path"
        kcount+=1
    done   
}

function get_vol_option {
    if [ "$Vol_option" = '-UUID' ] ; then
        echo '-d'
    else
        echo "$Vol_option"
    fi
}

function get_vol_path {
    if [ "$Vol_option" = '-UUID' ] ; then
        local uuid='' ; uuid=$(lsblk -n "$Vol_path" -o UUID)
        if [ -n "$uuid" ] ; then
            echo "$uuid"
        else
            echo "$Vol_path"
        fi
    else
        echo "$Vol_path"
    fi
}

#-----------------
# BEGIN
#-----------------

readonly Name=$1-$$
readonly Vol_option=$2 # (-d -f -UUID)
readonly Vol_path=$3
readonly Key_option=$4 # (-k)
readonly Key_path=$5

print_line
echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) BEGIN"
echo "testing $(grep 'readonly VERSION=' luksman|cut -f 2 -d ' ') mod $(date -r luksman '+%Y-%m-%dT%H:%M:%S') size $(wc -c luksman) md5 $(md5sum luksman)"
print_line

declare SAMPLE_TEXT_FILE='' ; SAMPLE_TEXT_FILE="/tmp/$(basename "$0" .sh)-$Name.tmp"
echo "writing sample data into $SAMPLE_TEXT_FILE"
create_sample_text_file "$SAMPLE_TEXT_FILE"
ls -l "$SAMPLE_TEXT_FILE"
print_line

if [ "$Vol_option" = '-f' ] ; then
    echo luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -s 32 -y
	if ! ./luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -s 32 -y ; then
        exit_error "$@"
    fi
else
    echo luksman create "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" -y
	if ! ./luksman create "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" -y ; then
        exit_error "$@"
    fi
fi
print_line

echo luksman mount "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path"
if ! ./luksman mount "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line

echo "writing sample data into /mnt/luksman/$Name/$(basename "$SAMPLE_TEXT_FILE")"
if ! cp "$SAMPLE_TEXT_FILE" "/mnt/luksman/$Name/" ; then
    exit_error "$@"
fi
print_line

echo luksman unmount "$Name"
if ! ./luksman unmount "$Name" ; then
    exit_error "$@"
fi
print_line

echo luksman newkey "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path"
if ! ./luksman newkey "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line

echo luksman mount "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path"
if ! ./luksman mount "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line

echo "reading sample data from encrypted volume"
if ! diff -s "$SAMPLE_TEXT_FILE" "/mnt/luksman/$Name/$(basename "$SAMPLE_TEXT_FILE")" ; then
    exit_error "$@"
fi
print_line

rm -f "$SAMPLE_TEXT_FILE"

echo luksman list
if ! ./luksman list ; then
    exit_error "$@"
fi
print_line

echo luksman unmount "$Name"
if ! ./luksman unmount "$Name" ; then
    exit_error "$@"
fi
print_line

echo luksman delete "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" -y
if ! ./luksman delete "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" -y ; then
    exit_error "$@"
fi
print_line

echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) SUCCESS"
print_line

exit 0

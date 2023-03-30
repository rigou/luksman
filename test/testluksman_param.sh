#!/bin/bash
# This script is part of the luksman test suite, see https://github.com/rigou/luksman
# it is a subprogram and should not be called from the command line

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
        local uuid=$(lsblk -n "$Vol_path" -o UUID)
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
readonly User="${SUDO_USER:-$USER}"

print_line
echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) BEGIN"
print_line
declare SAMPLE_TEXT_FILE='' ; SAMPLE_TEXT_FILE="/tmp/$(basename "$0" .sh)-$Name.tmp"
echo "writing sample data into $SAMPLE_TEXT_FILE"
create_sample_text_file "$SAMPLE_TEXT_FILE"
ls -l "$SAMPLE_TEXT_FILE"
print_line

if [ "$Vol_option" = '-f' ] ; then
	if ! ./luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -s 32 -y ; then
        exit_error "$@"
    fi
else
	if ! ./luksman create "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" -y ; then
        exit_error "$@"
    fi
fi
print_line

if ! ./luksman mount "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line

echo "writing sample data into /mnt/luksman/$Name/$(basename "$SAMPLE_TEXT_FILE")"
if ! cp "$SAMPLE_TEXT_FILE" "/mnt/luksman/$Name/" ; then
    exit_error "$@"
fi
ls -l "/mnt/luksman/$Name/" |grep -v lost+found
print_line

if ! ./luksman unmount "$Name" ; then
    exit_error "$@"
fi
print_line

if ! ./luksman newkey "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line

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
if ! ./luksman unmount "$Name" ; then
    exit_error "$@"
fi
print_line

if ! ./luksman delete "$Name" "$(get_vol_option)" "$(get_vol_path)" "$Key_option" "$Key_path" -y ; then
    exit_error "$@"
fi
print_line

echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) SUCCESS"
print_line

exit 0

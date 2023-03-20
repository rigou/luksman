#!/bin/bash

if [ $# -ne 5 ] ; then
	echo "usage: $(basename "$0") volume_name vol_option(-d -f) vol_path key_option(-k -l) key_path"
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
        LC_ALL=C tr -dc 'A-Za-z0-9_\+\-*/=,?;.:/!$&#{[|]}@%&$"~^' < /dev/urandom | head -c 999 >>"$path"
        echo >>"$path"
        kcount+=1
    done   
}

#-----------------
# BEGIN
#-----------------

readonly Name=$1-$$
readonly Vol_option=$2 # (-d -f)
readonly Vol_path=$3
readonly Key_option=$4 # (-k -l)
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
	if ! ./luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -o "$User" -s 32 ; then
        exit_error "$@"
    fi
else
	if ! ./luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -o "$User" ; then
        exit_error "$@"
    fi
fi
print_line
if ! ./luksman mount "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" ; then
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
if ! ./luksman newkey "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line
if ! ./luksman mount "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" ; then
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
if ! ./luksman delete "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
print_line
echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) SUCCESS"
print_line

exit 0

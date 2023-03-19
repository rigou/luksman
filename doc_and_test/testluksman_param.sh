#!/bin/bash

readonly User='rigou'

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

#-----------------
# BEGIN
#-----------------

declare Name=$1
declare Vol_option=$2 # (-d -f)
declare Vol_path=$3
declare Key_option=$4 # (-k -l)
declare Key_path=$5

print_line
echo "$(date '+%Y%m%dT%H%M') $(basename "$0" '.sh') $* (pid=$$) BEGIN"
print_line
if [ "$Vol_option" = '-f' ] ; then
	./luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -o $User -s 20
else
	./luksman create "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" -o $User
fi
if [ $? -ne 0 ] ; then
    exit_error "$@"
fi
print_line
if ! ./luksman mount "$Name" "$Vol_option" "$Vol_path" "$Key_option" "$Key_path" ; then
    exit_error "$@"
fi
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

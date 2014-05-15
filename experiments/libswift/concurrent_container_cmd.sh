#!/bin/bash -xe
# %*% Starts a lightweight web server in a container to seed a file of arbitrary size.

EXPECTED_ARGS=2
if [ $# -ne $EXPECTED_ARGS ]
then
	echo "Usage: `basename $0` output_dir filesize "
	exit 65
fi

# TODO use getopts
OUTPUT_DIR="$1"
FILESIZE="$2"

# start server
lighttpd -D -f $OUTPUT_DIR/lighttpd/lighttpd.conf &
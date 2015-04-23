#!/bin/bash -xe
# stats_crawler.sh ---
# Starts the statistics crawler.
# Author: Cor-Paul Bezemer
# Maintainer:
# Created: Feb 09 2015


# start one tribler instance that has some stuff to send around
if [ ! -z "$HOME_CRAWLER_FILE" ]; then
	if [ -e $HOME_CRAWLER_FILE ]; then
	    export HOME_SEED_FILE=$(readlink -f $HOME_FILE )
	    echo "HOME_SEED_FILE set to $HOME_SEED_FILE"
	else
		echo "The seed file was not found."
	fi
else
	echo "No seed file set."
fi
wrap_in_vnc.sh tribler/tribler.sh & 



STATEDIR="$OUTPUT_DIR/statsCrawler"

mkdir -p $STATEDIR/sqlite/

cd tribler/twisted
twistd --logfile=$STATEDIR/crawler.log --nodaemon bartercast_crawler --statedir=$STATEDIR &
sleep $PROCESS_GUARD_TIMEOUT
cd ../..

# if you want to run tests uncomment the following line
# wrap_in_vnc.sh run_nosetests_for_jenkins.sh

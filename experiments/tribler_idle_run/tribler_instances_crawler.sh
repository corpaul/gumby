#!/bin/bash -xe


INSTANCE=0
while [ $INSTANCE -lt $TRIBLER_INSTANCES ]; do
	let INSTANCE=1+$INSTANCE
	export INSTANCE_ID=$INSTANCE
	process_guard.py -t $PROCESS_GUARD_TIMEOUT -c 'wrap_in_vnc.sh gumby/experiments/tribler_idle_run/tribler_idle_run.py' -m $OUTPUT_DIR/$INSTANCE -o $OUTPUT_DIR/$INSTANCE &
done

export PYTHONPATH=$PYTHONPATH:$PWD/tribler

mkdir -p $OUTPUT_DIR/crawler/sqlite
# start crawler
cd tribler/Tribler
twistd -n -l- bartercast_crawler --statedir=$OUTPUT_DIR/crawler


wait


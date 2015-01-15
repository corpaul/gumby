#!/bin/bash -xe


INSTANCE=0
while [ $INSTANCE -lt $TRIBLER_INSTANCES ]; do
	let INSTANCE=1+$INSTANCE
	process_guard.py -t $PROCESS_GUARD_TIMEOUT -c 'wrap_in_vnc.sh gumby/experiments/tribler_idle_run/tribler_idle_run.py' -m $OUTPUT_DIR/$INSTANCE -o $OUTPUT_DIR/$INSTANCE &
done

export PYTHONPATH=$PYTHONPATH:$PWD/tribler

# start crawler
cd tribler/Tribler			
process_guard.py -t $PROCESS_GUARD_TIMEOUT -c 'twistd bartercast_crawler --statedir=$OUTPUT_DIR/crawler' -m $OUTPUT_DIR/crawler -o $OUTPUT_DIR/crawler &	
	
	
wait


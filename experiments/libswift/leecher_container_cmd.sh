#!/bin/bash -xe
# %*% Starts a libswift leecher (from run_experiment.sh), connects to a seeder and downloads a file. Note: runs inside a container.
# %*% start_seeder.sh must be started first.


EXPECTED_ARGS=22
if [ $# -ne $EXPECTED_ARGS ]
then
	echo "Usage: `basename $0` repository_dir dst_store hash netem_delay netem_packet_loss process_guard_cmd experiment_time bridge_ip seeder_ip seeder_port logs_dir leecher_id username rate_dl rate_ul iperf_test time debug_swift debug_ledbat concurrent_download concurrent_start_time concurrent_ip"
	exit 65
fi

# TODO use getopts
REPOSITORY_DIR="$1"
DST_STORE="$2"
HASH="$3"
NETEM_DELAY="$4"
NETEM_PACKET_LOSS="$5"
PROCESS_GUARD_CMD="$6"
EXPERIMENT_TIME="$7"
BRIDGE_IP="$8"
SEEDER_IP="${9}"
SEEDER_PORT="${10}"
LOGS_DIR="${11}"
LEECHER_ID="${12}"
USERNAME="${13}"
NETEM_RATE_DL="${14}"
NETEM_RATE_UL="${15}"
IPERF_TEST="${16}"
TIME="${17}"
DEBUG_SWIFT="${18}"
DEBUG_LEDBAT="${19}"
CONCURRENT_DOWNLOAD="${20}"
CONCURRENT_START_TIME="${21}"
CONCURRENT_IP="${22}"

# fix formatting for random variation
NETEM_DELAY=${NETEM_DELAY/'_'/' '}

IFS='_' read -ra RATE_DL <<< "$NETEM_RATE_DL"
RATE_DL=${RATE_DL[0]}
BURST_DL=${RATE_DL[1]}
IFS='_' read -ra RATE_UL <<< "$NETEM_RATE_UL"
RATE_UL=${RATE_UL[0]}
BURST_UL=${RATE_UL[1]}


# ----------------- works
# ingress traffic
tc qdisc add dev eth0 handle ffff: ingress
tc filter add dev eth0 parent ffff: protocol ip prio 50 \
   u32 match ip src 0.0.0.0/0 police rate $RATE_DL \
   burst $BURST_DL drop flowid :1

# egress traffic
tc qdisc add dev eth0 root handle 1: netem delay $NETEM_DELAY loss $NETEM_PACKET_LOSS

# add netem stuff
tc qdisc add dev eth0 parent 1: tbf rate $RATE_UL limit $BURST_UL burst $BURST_UL

# !--------------------

tc qdisc show

# leave here for testing TODO make configurable
if $IPERF_TEST;
then
	iperf -c 192.168.1.110 -r -w 64k -M 2000 -u -b 200M
else
	# leech file
	SWIFT_CMD="$REPOSITORY_DIR/swift -t $SEEDER_IP:$SEEDER_PORT -o $LOGS_DIR/dst/$LEECHER_ID -h $HASH -p "
	# add optional parameters iff set
	if [ "$TIME" -ne 0 ]; then
		SWIFT_CMD="$SWIFT_CMD -w $TIME"
	fi
	if $DEBUG_SWIFT; then
		SWIFT_CMD="$SWIFT_CMD -D $LOGS_DIR/dst/$LEECHER_ID/leecher_$LEECHER_ID "
	fi
	if $DEBUG_LEDBAT; then
		SWIFT_CMD="$SWIFT_CMD -L $LOGS_DIR/dst/$LEECHER_ID/ledbat_leecher_$LEECHER_ID "
	fi
	su $USERNAME -c "mkdir -p $LOGS_DIR/dst/$LEECHER_ID"
	su $USERNAME -c "$PROCESS_GUARD_CMD -c '${SWIFT_CMD}' -t $EXPERIMENT_TIME -o $LOGS_DIR/dst/$LEECHER_ID -m $LOGS_DIR/dst/$LEECHER_ID &"
	
	if $CONCURRENT_DOWNLOAD;
	then
		su $USERNAME -c "mkdir -p $LOGS_DIR/dst/$LEECHER_ID/concurrent"
		# @CONF_OPTION CONCURRENT_START_TIME: Time to wait before downloading the concurrent file
		su $USERNAME -c "sleep $CONCURRENT_START_TIME"
		su $USERNAME -c "wget http://$CONCURRENT_IP:3000/dl.zip -o $LOGS_DIR/dst/$LEECHER_ID/concurrent/dl.zip"
		wait
	fi
fi



#!/bin/bash -xe
# %*% Starts a lightweight web server in a container to seed a file of arbitrary size.

EXPECTED_ARGS=6
if [ $# -ne $EXPECTED_ARGS ]
then
	echo "Usage: `basename $0` output_dir CONCURRENT_DELAY CONCURRENT_PACKET_LOSS CONCURRENT_RATE CONCURRENT_RATE_UL USERNAME"
	exit 65
fi

# TODO use getopts
OUTPUT_DIR="$1"
NETEM_DELAY="$2"
NETEM_PACKET_LOSS="$3"
NETEM_RATE_DL="$4"
NETEM_RATE_UL="$5"
USERNAME="$6"

# fix formatting for random variation
# @CONF_OPTION SEEDER_DELAY: Netem delay for the seeder.
NETEM_DELAY=${NETEM_DELAY/'_'/' '}
# @CONF_OPTION SEEDER_RATE: Download rate limit for the seeder. Configure the rate as rate_burst, so e.g. seeder_rate="1mbit_100k"
IFS='_' read -ra RATE_DL <<< "$NETEM_RATE_DL"
RATE_DL=${RATE_DL[0]}
BURST_DL=${RATE_DL[1]}
# @CONF_OPTION SEEDER_RATE_UL: Upload rate limit for the seeder. Configure the rate as rate_burst, so e.g. seeder_rate_ul="1mbit_100k"
IFS='_' read -ra RATE_UL <<< "$NETEM_RATE_UL"
RATE_UL=${RATE_UL[0]}
BURST_UL=${RATE_UL[1]}

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

route add default gw 10.0.3.1
echo nameserver 8.8.8.8 >> /etc/resolv.conf

# start server
#su $USERNAME -c "/usr/sbin/lighttpd -f $OUTPUT_DIR/lighttpd/lighttpd.conf &"
#su $USERNAME -c "twistd -n web --path=$OUTPUT_DIR/lighttpd --l=$OUTPUT_DIR/lighttpd/twistd.log &"
#su $USERNAME -c "twistd -n web --path=$OUTPUT_DIR/lighttpd"
su $USERNAME -c "curl http://www.wswd.net/testdownloadfiles/100MB.zip -o $OUTPUT_DIR/dst/dl.zip 2> $OUTPUT_DIR/dst/curl-log "


#!/bin/bash -xe
# Note: runs on host (so not inside a container), used as tracker_cmd in gumby

WORKSPACE_DIR=$(readlink -f $WORKSPACE_DIR)
FILENAME=file_seed.tmp

# @CONF_OPTION DEBUG_SWIFT: Store libswift debug output (optional, default = false).
if [ -z "$DEBUG_SWIFT" ]; then
	DEBUG_SWIFT=false
fi

# @CONF_OPTION DEBUG_LEDBAT: Store ledbat debug output (optional, default = false).
if [ -z "$DEBUG_LEDBAT" ]; then
	DEBUG_LEDBAT=false
fi

# note: use 0.0.0.0:2000 for listening as using only the port will result in ipv6 communication
# between the leechers (i.e., they can't connect to each other)


# start seeder
# @CONF_OPTION SEEDER_IP: Full IP of seeder (e.g., 192.168.1.110)
# @CONF_OPTION SEEDER_PORT: Port for the seeder (e.g., 2000)
# @CONF_OPTION BRIDGE_NAME: Name of the network bridge of the host (e.g., br0).
# @CONF_OPTION BRIDGE_IP: IP of the network bridge of the host (e.g., 192.168.1.20).
sudo /usr/bin/lxc-execute -n seeder \
	-s lxc.network.type=veth \
	-s lxc.network.flags=up \
	-s lxc.network.link=$BRIDGE_NAME \
	-s lxc.network.ipv4=$SEEDER_IP/24 \
	-s lxc.rootfs=$CONTAINER_DIR \
	-s lxc.pts=1024 \
	-- $WORKSPACE_DIR/$SEEDER_CMD $WORKSPACE_DIR/swift $OUTPUT_DIR $FILENAME $SEEDER_DELAY $SEEDER_PACKET_LOSS $WORKSPACE_DIR/gumby/scripts/process_guard.py $EXPERIMENT_TIME $BRIDGE_IP $SEEDER_PORT $OUTPUT_DIR $USER $SEEDER_RATE $SEEDER_RATE_UL $IPERF_TEST $DEBUG_SWIFT $DEBUG_LEDBAT &


	#$SEEDER_CMD $REPOSITORY_DIR /$SRC_STORE $FILENAME $PROCESS_GUARD_CMD $DATE $EXPERIMENT_TIME $BRIDGE_IP $SEEDER_PORT &

# check if we have to seed concurrent downloads as well; if so, start a container for this
# @CONF_OPTION CONCURRENT_DOWNLOAD: Set to true if you want to concurrently download a file using wget.
#if $CONCURRENT_DOWNLOAD;
#then
	#mkdir -p $OUTPUT_DIR/lighttpd
	#printf "server.document-root = \"$OUTPUT_DIR/lighttpd\"\nserver.port = 23444\nserver.errorlog = \"$OUTPUT_DIR/lighttpd/errorlog\"\n" > $OUTPUT_DIR/lighttpd/lighttpd.conf
	#printf "server.modules += (\"mod_accesslog\")\naccesslog.filename = \"$OUTPUT_DIR/lighttpd/accesslog\"\ndebug.log-request-handling = \"enable\" " >>  $OUTPUT_DIR/lighttpd/lighttpd.conf
	#truncate -s $CONCURRENT_FILESIZE $OUTPUT_DIR/lighttpd/dl.zip

	# @CONF_OPTION CONCURRENT_IP: IP to start the httpd on.
	#	sudo /usr/bin/lxc-execute -n concurrentDL \
	#-s lxc.network.type=veth \
	#-s lxc.network.flags=up \
	#-s lxc.network.link=$BRIDGE_NAME \
	#-s lxc.network.ipv4=$CONCURRENT_IP/24 \
	#-s lxc.rootfs=$CONTAINER_DIR \
	#-s lxc.pts=1024 \
	#-- $WORKSPACE_DIR/$CONCURRENT_CMD $OUTPUT_DIR $CONCURRENT_DELAY $CONCURRENT_PACKET_LOSS $CONCURRENT_RATE $CONCURRENT_RATE_UL $USER &
#fi
#!/bin/bash -xe

# Run this before this script --------------------------------------------------
    # # build libswift
    # make -C $REPOSITORY_URL

    # # get and build LFS
    # if [ ! -d "$DIR_LFS" ]; then
    #     git clone git@github.com:vladum/lfs-libswift.git $DIR_LFS
    # else
    #     cd $DIR_LFS
    #     git pull origin master
    #     cd -
    # fi
    # make -C $DIR_LFS
# ------------------------------------------------------------------------------

if [ -z "$REPOSITORY_URL" ]; then
    echo "ERROR: REPOSITORY_URL variable not set, bailing out. (for libswift)"
    exit 2
fi

if [ ! -d "$REPOSITORY_DIR" -a ! -z "$REPOSITORY_DIR" ]; then
    svn co "$REPOSITORY_URL" "$REPOSITORY_DIR"
    cd $REPOSITORY_DIR && make
    cd -
fi

# Set defaults for config variables ---------------------------------------------------
# Override these on Jenkins before running the script.
[ -z $EXPERIMENT_TIME ] && EXPERIMENT_TIME=30
[ -z $FILE_SIZE ] && FILE_SIZE="1GiB"
# ------------------------------------------------------------------------------

echo "Running swift processes for $EXPERIMENT_TIME seconds"
echo "Workspace: $WORKSPACE_DIR"
echo "Output dir: $OUTPUT_DIR"

SRC_STORE=$OUTPUT_DIR/src/store
DST_STORE=$OUTPUT_DIR/dst/store

mkdir -p $SRC_STORE $DST_STORE

# logging
DATE=$(date +'%F-%H-%M')
LOGS_DIR=$OUTPUT_DIR/logs/$DATE
PLOTS_DIR=$OUTPUT_DIR/plots/$DATE
PLOTS_DIR_LAST=$OUTPUT_DIR/plots/last
mkdir -p $LOGS_DIR $PLOTS_DIR $PLOTS_DIR_LAST

df -h

FILENAME=file_$FILE_SIZE.tmp

# create data file
truncate -s $FILE_SIZE $SRC_STORE/$FILENAME

#hexdump -C -n 8192 $LFS_SRC_STORE/aaaaaaaa_128gb_8192

#META_ARCHIVE=$WORKSPACE/meta.tar.gz
#META_URL=https://dl.dropboxusercontent.com/u/18515377/Tribler/aaaaaaaa_128gb_8192.tar.gz

#ETAG=`awk '/.*etag:.*/ { gsub(/[ \t\n\r]+$/, "", $2); print $2 }' $META_ARCHIVE.headers | tail -1`
#wget --header="If-None-Match: $ETAG" -S --no-check-certificate -O $META_ARCHIVE $META_URL 2>&1 | tee $META_ARCHIVE.headers
#mkdir ${META_ARCHIVE}_dir || true
#tar xzvf $META_ARCHIVE -C ${META_ARCHIVE}_dir || true
#echo "Copying meta files. Please wait."
#cp ${META_ARCHIVE}_dir/* $LFS_SRC_STORE || true

#hexdump -C -n 60 -s 1597400 $LFS_SRC_STORE/aaaaaaaa_128gb_8192.mhash


#hexdump -C -n 8192 $LFS_SRC_STORE/$FILENAME

#mv $LFS_SRC_STORE/aaaaaaaa_128gb_8192 $LFS_SRC_STORE/$HASH
#mv $LFS_SRC_STORE/aaaaaaaa_128gb_8192.mbinmap $LFS_SRC_STORE/$HASH.mbinmap
#mv $LFS_SRC_STORE/aaaaaaaa_128gb_8192.mhash $LFS_SRC_STORE/$HASH.mhash

#ls -alh $LFS_SRC_STORE
#ls -alh $LFS_SRC_REALSTORE

#hexdump -C -n 8192 $LFS_SRC_STORE/$HASH

# compile SystemTap module
#$STAP_BIN -p4 -DMAXMAPENTRIES=10000 -t -r `uname -r` -vv -m cpu_io_mem_2 $DIR_LFS/stap/cpu_io_mem_2.stp >$LOGS_DIR/cpu_io_mem_2.compile.log 2>&1

# start source swift
#$STAP_RUN -R -o $LOGS_DIR/swift.src.stap.out -c "taskset -c 0 EXPERIMENT_TIMEout 60s $REPOSITORY_URL/swift -e $LFS_SRC_STORE -l 1337 -c 10000 -z 8192 --progress -D$LOGS_DIR/swift.src.debug" cpu_io_mem_2.ko >$LOGS_DIR/swift.src.log 2>&1 &

mkdir -p $LOGS_DIR/src
mkdir -p $LOGS_DIR/dst

$WORKSPACE_DIR/gumby/scripts/process_guard.py -c "taskset -c 0 $REPOSITORY_DIR/swift --uprate 307200 -f $SRC_STORE/$FILENAME -l 1337 -z 8192 --progress -H" -t $EXPERIMENT_TIME -m $LOGS_DIR/src -o $LOGS_DIR/src &
SWIFT_SRC_PID=$!

# wait for the hash to be generated
while [ ! -f $SRC_STORE/$FILENAME.mbinmap ] ;
do
      sleep 2
done

HASH=$(cat $SRC_STORE/$FILENAME.mbinmap | grep hash | cut -d " " -f 3)

echo $HASH

#echo "Starting destination in 5s..."
#sleep 5s

echo "Starting destination..."
# start destination swift
#$STAP_RUN -R -o $LOGS_DIR/swift.dst.stap.out -c "taskset -c 1 EXPERIMENT_TIMEout 50s $REPOSITORY_URL/swift -o $LFS_DST_STORE -t 127.0.0.1:1337 -h $HASH -z 8192 --progress -D$LOGS_DIR/swift.dst.debug" cpu_io_mem_2.ko >$LOGS_DIR/swift.dst.log 2>&1 &
touch $DST_STORE/$FILENAME
$WORKSPACE_DIR/gumby/scripts/process_guard.py -c "taskset -c 1 $REPOSITORY_DIR/swift --downrate 307200 -o $DST_STORE -f $FILENAME -t 127.0.0.1:1337 -h $HASH -z 8192 --progress" -t $(($EXPERIMENT_TIME-5)) -m $LOGS_DIR/dst -o $LOGS_DIR/dst &
SWIFT_DST_PID=$!

echo "Waiting for swifts to finish (~${EXPERIMENT_TIME}s)..."
wait $SWIFT_SRC_PID
wait $SWIFT_DST_PID

echo "---------------------------------------------------------------------------------"

# check LFS storage
ls -alh $SRC_STORE
ls -alh $DST_STORE

#sleep 10s

# --------- EXPERIMENT END ----------
#kill -9 $SWIFT_SRC_PID $SWIFT_DST_PID || true
#fusermount -z -u $LFS_SRC_STORE
#fusermount -z -u $LFS_DST_STORE
#kill -9 $LFS_SRC_PID $LFS_DST_PID || true
#pkill -9 swift || true

sleep 5s

# separate logs

# remove temps
#rm -rf $LFS_SRC_STORE
#rm -rf $LFS_DST_STORE
# rm -rf ./src ./dst # TODO

# ------------- LOG PARSING -------------

$WORKSPACE_DIR/gumby/experiments/libswift/parse_logs.py $LOGS_DIR/src
$WORKSPACE_DIR/gumby/experiments/libswift/parse_logs.py $LOGS_DIR/dst

# ------------- PLOTTING -------------
gnuplot -e "logdir='$LOGS_DIR/src';peername='src';plotsdir='$PLOTS_DIR'" $WORKSPACE_DIR/gumby/experiment/resource_usage.gnuplot
gnuplot -e "logdir='$LOGS_DIR/dst';peername='dst';plotsdir='$PLOTS_DIR'" $WORKSPACE_DIR/gumby/experiment/resource_usage.gnuplot

gnuplot -e "logdir='$LOGS_DIR';plotsdir='$PLOTS_DIR'" $DIR_LFS/experiment/speed.gnuplot

rm $PLOTS_DIR_LAST/*
cp $PLOTS_DIR/* $PLOTS_DIR_LAST/

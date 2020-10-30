#!/bin/bash
# Build maplab package in a low bandwidth environment.
# opencv3_catkin and suitesparse are esp. vulnerable to low bandwidth.
# often times, it is due to the error "Failed to connect to 
# raw.githubusercontent.com port 443: Connection refused". In this case,
# try this: open /etc/hosts, append the following line,
# 199.232.28.133 raw.githubusercontent.com
# see https://blog.csdn.net/CharlesYooSky/article/details/106354746

# maplab simulation package depends on orocos_kdl, you may need to install it with
# apt-get update
# apt-get install ros-kinetic-orocos-kdl
# If the problem "No rule to make target '/opt/ros/kinetic/lib/liborocos-kdl.so.1.3.0'"
# persist after installation, you may have to cheat a bit as below,
# ln -s /opt/ros/kinetic/lib/liborocos-kdl.so.1.3 /opt/ros/kinetic/lib/liborocos-kdl.so.1.3.0

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 </path/to/maplab_ws>" 
    exit 1
fi
MAPLAB_WS=$1
if [[ ! -d "$MAPLAB_WS" ]]; then
  echo "$MAPLAB_WS does not exist!"
  exit 2
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MAX_ATTEMPTS=5

cd $MAPLAB_WS

CMD="catkin build opencv3_catkin"
n=0
until [ $n -ge $MAX_ATTEMPTS ]
do
   $CMD && break  # substitute your command here
   $SCRIPT_DIR/download_opencv3_contrib_xfeatures2d.sh $MAPLAB_WS
   rm -rf $MAPLAB_WS/build/opencv3_catkin/opencv3_src/build/modules/xfeatures2d/*
   n=$(( $n+1))
   sleep 1
done

CMD="catkin build suitesparse"
n=0
until [ $n -ge $MAX_ATTEMPTS ]
do
   $CMD && break  # substitute your command here
   rm -rf $MAPLAB_WS/build/suitesparse/*
   n=$(( $n+1 ))
   sleep 2
done

CMD="catkin build maplab"
n=0
until [ $n -ge $MAX_ATTEMPTS ]
do
   $CMD && break  # substitute your command here
   n=$(( $n+1))
   sleep 2
done

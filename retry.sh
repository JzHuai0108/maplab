#!/bin/bash
# Build maplab package in a low bandwidth network.
# We build separately opencv3_catkin and suitesparse which are esp. vulnerable to low bandwidth.

# Troubleshooting
# 1. Network issue in building opencv3_catkin, "Failed to connect to 
# raw.githubusercontent.com port 443: Connection refused".

# One approach to resolve the issue is: open /etc/hosts, append the below line,
# 199.232.28.133 raw.githubusercontent.com
# see https://blog.csdn.net/CharlesYooSky/article/details/106354746

# An better approach is to register for a VPN service 
# which enables tunneling in a Linux terminal.

# 2. "No rule to make target '/opt/ros/kinetic/lib/liborocos-kdl.so.1.3.X'"
# This happens because the catkin compiler cannot locate 1.3.X though 
# it is very likely 1.3.0 or 1.3 can be located under /opt/ros/kinetic/lib.
# One approach is to be sure that liborocos has been installed, you may install it with
# apt-get update
# apt-get install ros-kinetic-orocos-kdl
# If the problem persists, you may have to hoax the compiler as below,
# ln -s /opt/ros/kinetic/lib/liborocos-kdl.so.1.3 /opt/ros/kinetic/lib/liborocos-kdl.so.1.3.X

# An alternative approach is from a [CSDN blog](https://blog.csdn.net/moyu123456789/article/details/106421754)
# where the liborocos is built from source and upgraded to 1.3.2.

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

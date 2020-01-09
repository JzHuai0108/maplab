#!/bin/bash
# Build maplab package in a low bandwidth environment.
# opencv3_catkin and suitesparse are esp. vulnerable to low bandwidth.

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 </path/to/maplab_ws>" 
    exit 1
fi
MAPLAB_WS=$1
if [[ ! -d "$MAPLAB_WS" ]]; then
  echo "$MAPLAB_WS does not exist!"
  exit 2 
fi

CMD="catkin build opencv3_catkin"
n=0
until [ $n -ge 20 ]
do
   $CMD && break  # substitute your command here
   rm -rf $MAPLAB_WS/build/opencv3_catkin/*
   n=$(( $n+1 ))
   sleep 5
done

CMD="catkin build suitesparse"
n=0
until [ $n -ge 20 ]
do
   $CMD && break  # substitute your command here
   rm -rf $MAPLAB_WS/build/suitesparse/*
   n=$(( $n+1 ))
   sleep 5
done

CMD="catkin build maplab"
n=0
until [ $n -ge 10 ]
do
   $CMD && break  # substitute your command here
   n=$(( $n+1))
   sleep 5
done

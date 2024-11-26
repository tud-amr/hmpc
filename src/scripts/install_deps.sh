#!/bin/bash

apt update

# Install ROS dependencies
rosdep update
if [ -z "$2" ]
then
    rosdep install -r -y --ignore-src --from-paths $1
else
    if [ -z "$3" ]
    then
    	rosdep install -r -y --ignore-src --from-paths $1 --dependency-types=$2
    else
        rosdep install -r -y --ignore-src --from-paths $1 --dependency-types=$2 --skip-keys="$3"
    fi
fi

apt clean
rm -rf /var/lib/apt/lists/*

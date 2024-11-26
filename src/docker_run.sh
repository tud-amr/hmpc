#!/bin/bash

# Define usage string
usage_str="Usage: ./run_docker.sh <sim/lab> <imagename> <yourname-yourproject-youralgorithm> (e.g. ./run_docker.sh hmpc-sim johndoe-paper-hmpc)"

# Process input arguments
if [ -z "$1" ]
then
    echo "No setup indication for sim or lab!"
    echo $usage_str
    exit 1
elif [ "$1" == "sim" ]
then
    is_sim=true
else
    is_sim=false
fi

if [ -z "$2" ]
then
    echo "No image name provided!"
    echo $usage_str
    exit 1
else
    image_name=$2
fi

if [ -z "$3" ]
then
    echo "No container name provided!"
    echo $usage_str
    exit 1
else
    container_name=$3
fi

if [ "$is_sim" = true ]
then
    echo "Starting Docker container $container_name from image $image_name for simulations"
else
    echo "Starting Docker container $container_name from image $image_name for lab experiments"
fi

# Run the Docker container
if [ "$is_sim" = true ]
then
    xhost +local:docker

    docker run \
        -e "DISPLAY=$DISPLAY" \
        -e "QT_X11_NO_MITSHM=1" \
        -it \
        --mount type=bind,source=./catkin_ws/src,target=/root/dev/catkin_ws/src \
        --name $container_name \
        --network="host" \
        --privileged \
        -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        $image_name
else
    docker run \
        -it \
        --name $container_name \
        --network="host" \
        --privileged \
        $image_name
fi

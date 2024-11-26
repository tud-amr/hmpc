#! /bin/bash

# Define usage string
usage_str="Usage: ./docker_build.sh <sim/lab> <imagename> (<args>) (e.g. ./build_docker.sh lab hmpc-lab or ./build_docker.sh sim hmpc-sim --no-cache)"

# Check if there are at least 2 arguments
if [ $# -lt 2 ];
then
    echo "Not enough arguments. Expecting at least 2 arguments."
    echo $usage_str
    exit 1
else
    if [ "$1" == "sim" ]
    then
        is_sim=true
    else
        is_sim=false
    fi
    dockerfile_name="Dockerfile.$1"
    image_name=$2
    echo "Building Docker image with name $image_name using Dockerfile $dockerfile_name"
fi

# Shift the first two arguments, so the rest can be provided as additional arguments to the docker build
shift 2
if [ -z "$1" ]
then
    echo "No additional arguments provided."
else
    echo "Additional arguments provided: $@"
fi

# Build the Docker image for simulations with git information about PX4-Autopilot (for building the package) and for the lab with all the contents of this repository (for version control in the container)
export DOCKER_BUILDKIT=1
if [ "$is_sim" = true ]
then
    mkdir -p .git/modules/src/PX4-Autopilot
    cp -r ../.git/modules/src/PX4-Autopilot ./.git/modules/src
    docker build -f $dockerfile_name -t $image_name $@ .
    sudo rm -rf .git
else
    docker build -f $dockerfile_name -t $image_name $@ ..
fi

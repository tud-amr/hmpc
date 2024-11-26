#!/bin/bash

cur_dir=$(pwd)

cd $PX4
DONT_RUN=1 PX4_SIM_SPEED_FACTOR=1 make px4_sitl_default gazebo
# VERBOSE_SIM=1 DONT_RUN=1 PX4_SIM_SPEED_FACTOR=1 make px4_sitl_default gazebo
# DONT_RUN=1 PX4_SIM_SPEED_FACTOR=1 make px4_sitl_default gazebo___windy
cd $cur_dir

source $PX4/Tools/setup_gazebo.bash $PX4 $PX4/build/px4_sitl_default >/dev/null
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PX4
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$PX4/Tools/sitl_gazebo

# Lab experiments
Let's complete the steps for the lab experiments!

Contents:\
[Preliminary notes](#preliminary-notes)\
[Required components](#required-components)\
[Set up the lab environment](#set-up-the-lab-environment)\
[Set up the GCS and quadrotor NVIDIA Jetson Xavier NX onboard computer and PX4 flight controller](#set-up-the-gcs-and-quadrotor-nvidia-jetson-xavier-nx-onboard-computer-and-px4-flight-controller)\
[Run](#run)\
[Troubleshooting](#troubleshooting)



## Preliminary notes
In the lab experiments setup, all the repository content is copied into the Docker container. This means:
1. Once the Docker image is built and the container is created, you can work in a self-contained environment with less chance that other people using the onboard computer might accidentally break your setup.
2. You do version control from within the container. This can be easily set up by adding the following lines to the *~/.ssh/config* file on your host machine:
    ```
    Host <ssh_connection_name>
        User <user_name_onboard_computer>
        HostName <ip_address_onboard_computer>
        IdentityFile ~/.ssh/<your_ssh_id_file>
        ForwardAgent yes
    ```
    where *Host* is a custom name you can give to this SSH configuration, the *User* is the username on the onboard computer, the *HostName* is the IP address of the onboard computer, the *IdentityFile* is the path to the SSH key you use to connect to GitHub on your host machine, and *ForwardAgent yes* allows you to forward your SSH key through the SSH tunnel to the onboard computer. If you open VS Code, connect via this SSH configuration to the onboard computer, connect to the running container, and open a terminal there, you are able to perform Git commandline operations with proper GitHub authorization.
    
    See [this page](https://code.visualstudio.com/docs/containers/overview) for more information on how to use Docker inside VS Code.

    > :bulb: It could be useful to add the following lines to the *~/.bashrc* file in the Docker container on the onboard computer:
    > ```bash
    > export GIT_AUTHOR_NAME=<your_github_username>
    > export GIT_AUTHOR_EMAIL=<your_github_email>
    > ```
    > This way, the commit you do from inside the container will be associated with your GitHub account, so it is easier to track who did what in the repository.



## Required components
List of components:
- Lab with Vicon motion capture system and Wi-Fi network
- HoverGames quadrotor platform (includes flight controller with flashed PX4 autopilot)
- Charger of NVIDIA Jetson Xavier NX onboard computer
- LiPo 4S 4000 mAh batteries
- Remote RC controller
- Telemetry radio
- Ground Control Station (GCS): the computer you use to communicate with the robot

> :information_source: For reproducibility, the following PX4 files are included in [*px4_files*](./px4_files): compiled autopilot code (*.px4*), autopilot parameters (*.params*) and *extras.txt* to load on the SD card in the *etc* directory. The compiled autopilot code is generated using a modified version of stable release [v1.12.3](https://github.com/PX4/PX4-Autopilot/tree/v1.12.3) of the [PX4-Autopilot](https://github.com/PX4/PX4-Autopilot) open-source project, see [this fork](https://github.com/cor-drone-dev/PX4-Autopilot) for details.



## Set up the lab environment
1. Power the motion capture system, start the Vicon Tracker program, and leave it one for a while to warm up the cameras.

2. After the cameras are warmed up, create the Vicon object for the quadrotor. Make sure that the object center is aligned with the geometric center of the quadrotor.



## Set up the GCS and quadrotor NVIDIA Jetson Xavier NX onboard computer and PX4 flight controller
1. Start the onboard computer by connecting it using its power adapter to the grid. This avoids consuming power from the LiPo battery. Start the GCS as well.

2. Connect both the GCS and the onboard computer to the lab Wi-Fi network.

3. Using the GCS, SSH into the onboard computer over the lab Wi-Fi, clone this repository, and follow the instructions up to and including step 3 in the [build instructions](./README.md#build) in the [src README](./README.md).

4. During the Docker build time on the onboard computer, clone this repository on the GCS and follow all [build instructions](./sim.md#build) in [sim.md](./sim.md) with the following changes:
    - Add the following lines to the *~/.bashrc* file in the container on the GCS:
        ```bash
        export ROS_MASTER_URI=http://<ip_address_onboard_computer>:11311
        export ROS_IP=<ip_address_gcs>
        ```
    - Make sure to use `set(PLATFORM "hovergames_px4")` in the [*CMakeLists.txt*](./catkin_ws/src/mpc/mpc_systems/mpc_hovergames/CMakeLists.txt) file.

5. In the SSH terminal to the onboard computer, follow the instructions up to and including step 3 in the [build instructions](./sim.md#build) in [sim.md](./sim.md) to start the container with the following changes:
    - Add the following lines in the *~/.bashrc* file in the Docker container on the onboard computer:
        ```bash
        export ROS_MASTER_URI=http://<ip_address_onboard_computer>:11311
        export ROS_IP=<ip_address_onboard_computer>
        ```
    - Make sure to use `set(PLATFORM "hovergames_px4")` in the [*CMakeLists.txt*](./catkin_ws/src/mpc/mpc_systems/mpc_hovergames/CMakeLists.txt) file.

6. After having generated the solver as explained in the [src README](./README.md#build) instructions, copy the *hovergames* directory in the [include](./catkin_ws/src/mpc/mpc_solver/include/mpc_solver/) and [src](./catkin_ws/src/mpc/mpc_solver/src) directories and the file *cmake_globalvars.cmake* in the [src](./catkin_ws/src/mpc/mpc_solver/src) directory to their respective directories in the Docker container on the onboard computer. You can do so by dragging and dropping the files in VS Code. Then, in the *pmpc/smpc/tmpc_FORCESNLPsolver* directory, remove the directory `lib` containing the solver compatible with the CPU architecture of the GCS and rename `lib_target` to `lib`, which contains the solver compatible with the CPU architecture of the onboard computer. Repeat this step for all the solvers you want to run on the onboard computer.

7. Start the tmuxinator project in the Docker container on the onboard computer and build the required packages in the catkin workspace:
```bash
shmpc
catkin build mpc_hovergames vicon_bridge
```

8. After this build step is finished, start QGroundControl (QGC) in a new terminal window on the GCS. See the [QGC website](https://qgroundcontrol.com) for documentation and installation instructions.

9. Connect the telemetry radio via USB to the GCS.

10. Connect the LiPo battery on the quadrotor platform.

11. Disconnect the power adapter from the onboard computer.

    > :bulb: By first connecting the LiPo battery, the onboard computer is continuously powered so there is no need to reboot.

12. Make sure that QGC can properly receive data from the flight controller.

13. Power the RC controller.



## Run
Exciting! Ready to run the lab experiments?

1. In the container on the onboard computer, double-check if the [PX4 control interface](./catkin_ws/src/drone_toolbox/px4_tools/src/px4_control_interface.cpp) parameters are set correctly in [*px4_control_interface_mpc.yaml*](./catkin_ws/src/drone_toolbox/px4_tools/config/px4_control_interface_mpc.yaml). This includes parameters such as the takeoff $z$ position and lab bounds.

2. Familiarize yourself with the RC controller by reading its configuration in QGC. In QGC, click on the top left button, then *Application Settings*, then *Radio*. See [this link](https://docs.qgroundcontrol.com/master/en/qgc-user-guide/setup_view/radio.html) for more information.

3. Familiarize yourself with the following graceful degradation rules:
    1. If the lab bounds are set correctly in [*px4_control_interface_mpc.yaml*](./catkin_ws/src/drone_toolbox/px4_tools/config/px4_control_interface_mpc.yaml), the flight controller will automatically switch to landing mode upon hitting one of the boundaries. This prevents from crashing against the lab surroundings.
    2. In case the pose data from motion capture system is not received for more than 0.5 s, the [PX4 control interface](./catkin_ws/src/drone_toolbox/px4_tools/src/px4_control_interface.cpp) will print the error message `Mocap data lost for over half a second, switching to LANDING mode`. As a result, the quadrotor will land.
    3. In case the algorithm code fails: switch back to position mode and the autopilot will stabilize the platform. You can land the quadrotor in position mode and subsequently disarm the motors.
    4. If position mode fails, switch to manual control mode and accept the challenge of manually controlling the quadrotor ;)
    5. If people are at danger, or in any other dangerous case, kill the motors.

4. In the container on the onboard computer, go to the second terminal window (`roscore`) using shift+arrow-right and press arrow-up and enter to run:
    ```bash
    roscore
    ```

5. Go to the third terminal window (`run`). See step 1 in the [run instructions](./sim.md#run) in [sim.md](./sim.md) for more information. In this case, run the following command in the top-left pane:
    ```bash
    run_px4_2_base_lab
    ```

6. In the container on the GCS, go to the second terminal window (`run`) and run the following command in the top-left pane:
    ```bash
    run_gcs_2
    ```
    This will start the GUI applications used to run the simulations and lab experiments. Check if RViZ visualizes the map, the quadrotor pose, and the obstacles correctly.

7. If everything is visualized correctly, start the algorithm code in the container on the onboard computer. In the third terminal window (`run`), run the following commands in the bottom-left pane:
    ```bash
    run_px4_2_0_lab
    ```
    and in the bottom-right pane:
    ```bash
    run_px4_2_1_lab
    ```

8. It's time to fly! Perform the following steps using the RC controller:
    - Switch the flight controller to position mode.
    - Arm the quadrotor.
    - Switch the flight controller to offboard mode. The quadrotor will now automatically take off and execute the algorithm code.
    - Increase the thrust value to half of its range so you can quickly switch back to position mode while keeping altitude in case something goes wrong in your algorithm.

9. Publish a goal. See step 2 in the [run instructions](./sim.md#run) in [sim.md](./sim.md) for more information. Make sure the right environment (`--exp_type exp`) is selected.

10. Enjoy the flight! :)



## Troubleshooting
**I can successfully run `rostopic list`, but not `rostopic echo <TOPIC_NAME>`. How to resolve?**

Check if the `ROS_MASTER_URI` and `ROS_IP` environment variables are set correctly in the *~/.bashrc* files in both the container running on the onboard computer and the container running on the GCS. There is no need to set these variables in the hosts of both computers. According to the instructions above, the ROS core is run in the container on the embedded computer. Therefore, the `ROS_MASTER_URI` should match the `ROS_IP` on the onboard computer. On the GCS, the `ROS_MASTER_URI` should be the same as on the onboard computer and the `ROS_IP` should match the GCS IP address.

**QGC does not receive any telemetry data from the flight controller. How to resolve?**

Follow these steps:
1. Check the hardware: are the telemetry radios on both sides powered and properly connected to the flight controller and GCS?
2. Restart QGC.
3. Reboot the flight controller. You can either do this by re-plugging the power cable to the flight controller or using QGC by clicking on the top left button, then *Application Settings*, then *Parameters*, then *Tools*, then *Reboot vehicle*.

**The flight controller does not want to enter position mode. How to resolve?**

If the ROS core is running and the `run_px4_2_base_lab` is actively running in a terminal in the container on the onboard computer this is most likely caused by the fact that the flight controller and onboard computer cannot communicate with each other. As a result, the pose data from the motion capture system is not received on the flight controller side and the autopilot cannot fly in position control mode. This could happen after switching a LiPo battery, while keeping the onboard computer powered. To solve this, go to QGC, then *Analyze Tools*, then *MAVLink Console*, then subsequently type `ifconfig`, `ifdown eth0`, `ifup eth0`, `ifconfig`, and check if the IP address of the flight controller has changed from zero to non-zero. This IP address should match the one in the `fcu_url` parameter in [px4_tools.launch](./catkin_ws/src/drone_toolbox/px4_tools/launch/px4_tools.launch)!

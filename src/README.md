# Source code
Let's install, build and run!

Contents:\
[Preliminary notes](#preliminary-notes)\
[Overview](#overview)\
[Install](#install)\
[Build](#build)\
[Run](#run)



## Preliminary notes
1. We have tried to make the setup as user-friendly as possible. As a result, there is great overlap in the steps to take for running a simulation and a lab experiment. All the common instructions are written here, while the specific instructions for simulations and lab experiments are written in [sim.md](./sim.md) and [lab.md](./lab.md), respectively.

2. All software is tested on a machine running Ubuntu 20.04.6 LTS with Robot Operating System (ROS) Noetic. The setup should work on other Ubuntu versions as well, but we cannot guarantee this. If you encounter any issues, please let us know by creating an issue in this repository.

3. Note that some links in this and other READMEs do not work on [github.com](https://github.com). To view the links, clone the repository including all its submodules and open the READMEs in your favourite editor.

4. Interested in using this setup for your own system? This is certainly possible! Our [MPC](./catkin_ws/src/mpc) package can easily be extended to other robotic platforms and tasks by defining different models, objectives, constraints, etc. Furthermore, it supports data logging, visualization, and real-time performance evaluation.

5. Are you using a PX4-powered quadrotor platform? Check out our [drone_toolbox](/src/catkin_ws/src/drone_toolbox) package and [our fork of PX4-Autopilot](./PX4-Autopilot)! We can communicate the hover thrust estimate via [our fork of mavros](./catkin_ws/src/mavros) to any ROS node. This is useful if you want to control the quadrotor with body rate or attitude commands.



## Overview
The setup consists of several submodules, each with its own purpose.
| **Package** | **Description** |
|-------------|-----------------|
| [**PX4-Autopilot**](./PX4-Autopilot) | PX4 Autopilot software stack used to run the PX4 Gazebo software-in-the-loop (SITL) simulations and compile the binaries to flash on the flight controller of the quadrotor platform. |
| [**DecompUtil**](./catkin_ws/src/DecompUtil) | Convex decomposition algorithm used to construct convex obstacle-free regions per stage in the MPC horizon. |
| [**drone_toolbox**](./catkin_ws/src/drone_toolbox) | ROS toolbox for simulator and system identification and for running simulation and lab experiments with a PX4-powered quadrotor. |
| [**drone_toolbox_ext_control_template**](./catkin_ws/src/drone_toolbox_ext_control_template) | Template control package showing how to run simulations and lab experiments using the [*drone_toolbox*](./catkin_ws/src/drone_toolbox). |
| [**mav_comm**](./catkin_ws/src/mav_comm) | ROS message and service definitions used to communicate with Micro Aerial Vehicles (MAVs). |
| [**mavlink-gbp-release**](./catkin_ws/src/mavlink-gbp-release) | MAVLink communication protocol used to communicate with MAVs. |
| [**mavros**](./catkin_ws/src/mavros) | MAVLink to ROS gateway with proxy for Ground Control Station (GCS). |
| [**mpc**](./catkin_ws/src/mpc) | Modular MPC code framework used for trajectory optimization of nonlinear mobile robots. |
| [**mpc/mpc_solver/scripts/include/offline_computations/mpc-sdp**](./catkin_ws/src/mpc/mpc_solver/scripts/include/offline_computations/mpc-sdp) | MATLAB code to run the offline terminal ingredients design. |
| [**occupancygrid_creator**](./catkin_ws/src/occupancygrid_creator) | ROS package to create an occupancy grid from the geometrical shape of obstacles, either statically defined or received via a motion capture system. |
| [**simple_sim**](./catkin_ws/src/simple_sim) | Simple simulation environment without model mismatch. |
| [**vicon_bridge**](./catkin_ws/src/vicon_bridge) | ROS package to communicate with Vicon motion capture systems. |



## Install
### GitHub
We recommend setting up your connection with GitHub using SSH. See [this page](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) for more information.


### Docker
Install [Docker](https://docs.docker.com/) by following the instructions on [this page](https://docs.docker.com/get-started/get-docker). Give Docker sudo rights by following the instructions on [this page](https://docs.docker.com/engine/install/linux-postinstall/).


### Python 3
The solver generation code in the [MPC](./catkin_ws/src/mpc) repository requires Python 3. See the [MPC README](./catkin_ws/src/mpc/README.md) for more information.


### ForcesPro license
The MPC implementations use a ForcesPro solver. Therefore, first request a ForcesPro license and install the client. To this end, follow the corresponding instructions in the [MPC README](./catkin_ws/src/mpc/README.md).


### MATLAB and packages
Please refer to the [MPC-SDP README](./catkin_ws/src/mpc/mpc_solver/scripts/include/offline_computations/mpc-sdp/README.md) for the MATLAB version and packages that were used to run the offline terminal ingredients design.



## Build
The build instruction differ between simulations and lab experiments. First execute the following common instructions:

1. Go to the `src` directory of this repo (important to prevent deleting the *.git* directory in your local repo clone):
    ```bash
    cd src
    ```

2. Build the Docker image by filling in the required arguments:
    ```bash
    sudo ./docker_build.sh
    ```
    Give the Docker image a descriptive name, such as *hmpc-sim* or *hmpc-lab*.

3. Create and run container from the built image by filling in the required arguments:
    ```bash
    ./docker_run.sh
    ```
    Give the Docker container a descriptive name, such as *dennis-paper-hmpc*. From now on, we refer to the container with this name.

4. Exit the container and source the following aliases in the *~/.bashrc* file on your host machine:
    ```bash
    alias cdmpcsolver='cd <path_to_repo>/src/catkin_ws/src/mpc/mpc_solver'
    alias mpc_generate_solver_hmpc='cdmpcsolver; ./setup_script.sh -c tmpc_settings.py -c pmpc_settings.py -s hovergames -f ARM'
    alias mpc_generate_solver_smpc='cdmpcsolver; ./setup_script.sh -c smpc_settings.py -s hovergames -f ARM'
    ```
    where `<path_to_repo>` is the path to this repository on your host machine.

5. After sourcing the aliases, generate the HMPC solver:
    ```bash
    mpc_generate_solver_hmpc
    ```
    or the SMPC solver:
    ```bash
    mpc_generate_solver_smpc
    ```
    In the [mpc_solver](./catkin_ws/src/mpc/mpc_solver) package, this will generate a directory *hovergames* in the [include](./catkin_ws/src/mpc/mpc_solver/include/mpc_solver/) and [src](./catkin_ws/src/mpc/mpc_solver/src) directories and a file *cmake_globalvars.cmake* in the [src](./catkin_ws/src/mpc/mpc_solver/src) directory.

6. Now, refer to [sim.md](./sim.md) and [lab.md](./lab.md) for the specific instructions to run simulations and lab experiments.

    In the Docker simulation and lab images, we have added a tmuxinator project that you can start using `shmpc`, attach to using `ahmpc` and kill using `khmpc`. This is the recommended way to work in the container and is assumed to be used in the remaining instructions. See the [tmuxinator](https://github.com/tmuxinator/tmuxinator) and [tmux](https://github.com/tmux/tmux/wiki) pages for more information.

    > :information_source: Compared to the default tmux settings, we have changed the prefix key to `Ctrl-a` for convenience of usage, see the [tmux.conf](./config_files/dotfiles/.tmux.conf) file for more information.



## Run
The run instructions differ between simulations and lab experiments. Refer to [sim.md](./sim.md) and [lab.md](./lab.md) for the specific instructions.

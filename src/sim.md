# Simulations
Let's complete the build steps and run the simulations!

Contents:\
[Preliminary notes](#preliminary-notes)\
[Build](#build)\
[Run](#run)



## Preliminary notes
In the simulations setup, the source code is mounted into the container. This means that you can edit the source code on your host machine and run the simulations inside the container. As a result, you can use your favourite GitHub client on your host machine to manage the source code. Our recommendation is to use [GitKraken](https://www.gitkraken.com). You can connect with it using a [GitHub pro account](https://docs.github.com/en/get-started/learning-about-github/githubs-plans) that you can request using the [GitHub Student Developer Pack](https://education.github.com/pack).



## Build
1. If not yet connected to the Docker container, do so by running:
    ```bash
    docker start dennis-paper-hmpc
    docker attach dennis-paper-hmpc
    ```

    > :bulb: Include the following lines in the *~/.bashrc* file on your host machine to speed up this process:
    > ```bash
    > alias dshmpc='docker start dennis-paper-hmpc'
    > alias dahmpc='docker attach dennis-paper-hmpc'
    > ```

    > :bulb: Alternatively, you can connect to the running container using VS Code. See [this page](https://code.visualstudio.com/docs/containers/overview) for more information.

2. Open the *~/.bashrc* file in the container by using vim:
    ```bash
    vim ~/.bashrc
    ```
    scroll down with the arrow keys and add the following lines at a location that makes sense to you:
    ```bash
    export ROS_MASTER_URI=http://localhost:11311
    export ROS_IP=<your_ip_address>
    ```
    Here, `<your_ip_address>` is the current IP address of your host machine. Obtain it by running `ifconfig` in another terminal window. Since the container uses the network of the host machine, this IP address is also used inside the container.

3. Select the proper MPC interface in the [*CMakeLists.txt*](./catkin_ws/src/mpc/mpc_systems/mpc_hovergames/CMakeLists.txt) file in the [mpc_hovergames](./catkin_ws/src/mpc/mpc_systems/mpc_hovergames) package. Use either `set(PLATFORM "hovergames_simplesim")` for running simple simulations or `set(PLATFORM "hovergames_px4")` for running Gazebo simulations with the PX4 autopilot.

    > :information_source: More information on the setup with the PX4 autopilot can be found in the [drone_toolbox](./catkin_ws/src/drone_toolbox) package in this repository.

4. Now, start the tmuxinator project:
    ```bash
    shmpc
    ```
    and build the required packages in the catkin workspace by pressing arrow-up and completing as:
    ```bash
    catkin build mpc_hovergames
    ```

5. Source the workspace. The easiest way to do this is to restart the tmux session by pressing ctrl+a, then d, running `khmpc`, and running `shmpc` again.



## Run
Let's run a simulation!

1. Go to the second terminal window (`run`) using shift+arrow-right. This gives four terminal panes. Each of these panes has a history of commands that you can easily select by pressing arrow-up one or multiple times. The commands all have the same syntax and are defined as aliases in the *~/.bashrc* file:
    ```bash
    run_<interface>_<n_layers>(_<base/layer_idx>_<sim/lab>)
    ```
    with:
    - `<interface>` is the platform interface that you set in the [*CMakeLists.txt*](./catkin_ws/src/mpc/mpc_systems/mpc_hovergames/CMakeLists.txt) file: either simplesim (`ss`) or PX4 (`px4`)
    - `<n_layers>` is the number of MPC layers to run and selects between HMPC (`2`) and SMPC (`1`). This should correspond with the solver that you have generated.
    - `<base/layer_idx>` selects between running the ROS environment except for the MPC node(s) (`base`) or running the MPC layer with index `<layer_idx>` in HMPC (`0` and `1`). Leave empty to run SMPC.
    - `<sim/lab>` selects between running a simulation (`sim`) or lab experiment (`lab`) when using the PX4 interface.

    For example, to run HMPC in simplesim, run in the top-left pane:
    ```bash
    run_ss_2_base
    ```
    in the bottom-left pane:
    ```bash
    run_ss_2_0
    ```
    and in the bottom-right pane:
    ```bash
    run_ss_2_1
    ```

    Note that the MPC schemes require your ForcesPro license to be verified. To avoid license errors during flight, we run the solver once without valid data. Therefore, you should get a warning similar to the following one during initialization:
    ```bash
    [Solver] The solver could not proceed. Check the ForcesPro documentation for more information (exit_code = -7)
    ```

2. Both HMPC and SMPC are goal-oriented schemes, so they will hover by default since the goal is constant. A new goal can easily be provided via the top-right pane. Again, press arrow-up and make sure the right environment (`--exp_type <sim/gaz>`) is selected.

    For example, to publish two goals in simplesim, run in the top-right pane:
    ```bash
    goal_publisher.py --exp_type sim --d_min 0.02 --d_dim 2 --goals -2.2 -1.4 1.4 0 2.2 1.4 1.4 0
    ```

3. Have fun playing around with HMPC or SMPC in simple or Gazebo simulations :)

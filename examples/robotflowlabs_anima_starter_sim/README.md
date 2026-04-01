# RobotFlowLabs ANIMA Simulation Starter

This starter launches a reproducible Gazebo scene on the ANIMA noVNC desktop.

Use it when you want a visible simulation outcome as the first proof point:

```bash
./anima starter run starter-sim
```

If you want the manual in-container path instead:

```bash
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 launch robotflowlabs_anima_starter_sim starter_sim.launch.py
```

What you should see:

- Gazebo running on the noVNC desktop
- `/clock` bridged into ROS 2
- `ANIMA sim starter confirmed ROS graph activity on /clock.`

Optional companion flow:

```bash
./anima foxglove sim
```

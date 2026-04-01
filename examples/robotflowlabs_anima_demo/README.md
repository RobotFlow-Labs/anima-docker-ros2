# RobotFlowLabs ANIMA Workspace Readiness Starter

This package is the minimal first-run check for ANIMA.

It answers one question fast: is the workspace healthy enough to begin real work?

Build and run it inside ANIMA:

```bash
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 run robotflowlabs_anima_demo hello_anima
```

What you should see:

- the ROS 2 distro in the logs
- a clear message that the workspace is ready
- a recurring heartbeat showing the container is alive

Use this package when you want the smallest possible proof that the desktop and ROS 2 runtime are working.

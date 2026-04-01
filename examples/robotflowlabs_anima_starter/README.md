# RobotFlowLabs ANIMA Visualization Starter

This is the default first-run visualization starter for ANIMA.

It gives you one launch command that proves three things at once:

- the workspace is healthy
- ROS 2 nodes can publish and subscribe
- the desktop is already useful before any custom code is written

Build and run it inside ANIMA:

```bash
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 launch robotflowlabs_anima_starter starter_demo.launch.py
```

What you should see:

- a workspace-ready heartbeat from `robotflowlabs_anima_demo`
- `ANIMA starter talker is publishing on /anima/starter`
- `heard ANIMA starter message ...` from the listener

If you want the minimal readiness check only, use `robotflowlabs_anima_demo`.
If you want the pure graph exercise only, use `robotflowlabs_anima_pubsub`.

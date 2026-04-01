# RobotFlowLabs ANIMA ROS 2 Graph Starter

This package adds a minimal ROS 2 talker/listener pair plus a launch file.

It is the smallest useful end-to-end graph demo in ANIMA: a publisher sends messages, a listener receives them, and the logs prove the transport works.

Build and run it inside ANIMA:

```bash
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 launch robotflowlabs_anima_pubsub pubsub_demo.launch.py
```

What you should see:

- `ANIMA starter talker is publishing on /anima/starter`
- `Publishing ANIMA starter message ...`
- `heard ANIMA starter message ...`

Use this package when you want to verify the ROS graph and message delivery, not just package import and build success.

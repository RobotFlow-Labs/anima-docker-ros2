# RobotFlowLabs ANIMA Synthetic Sensors Starter

This starter publishes deterministic camera and lidar-style topics so Foxglove has something useful to inspect immediately.

Use it when you want a lightweight proof flow without external bags or datasets:

```bash
./anima starter run starter-sensors
./anima foxglove dev
```

If you want the manual in-container path instead:

```bash
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 launch robotflowlabs_anima_starter_sensors starter_sensors.launch.py
```

What you should see:

- a deterministic RGB image topic at `/anima/sensors/front_camera/image_raw`
- a deterministic scan topic at `/anima/sensors/front_lidar/scan`
- periodic logs showing sensor frames are publishing

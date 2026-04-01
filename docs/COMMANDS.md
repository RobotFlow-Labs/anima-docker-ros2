# RobotFlowLabs ANIMA Commands

The repo exposes the same workflow through three surfaces:

- `./anima` for the branded CLI
- `make` targets for simple terminal use
- `./scripts/compose.sh` when you want raw Docker Compose access with env auto-selection

## Recommended Commands

```bash
./anima up
./anima status
./anima password
./anima shell
./anima starter list
./anima starter run starter-visualization
./anima starter run starter-sim
./anima starter run starter-sensors
./anima foxglove dev
./anima stop
```

## Profiles

```bash
./anima up desktop
./anima up dev
./anima up sim
```

With runtime options:

```bash
./anima up --bind ./workspace
./anima up dev --dds cyclonedds
./anima foxglove dev --dds cyclonedds
./anima up --transport webrtc
./anima up --hardware usb
./anima up --hardware serial
```

`--transport webrtc` remains preview-only. The default transport is still noVNC.

Equivalent Make targets:

```bash
make up
make up-dev
make up-sim
make up-usb
make up-serial
make up-camera
make up-audio
```

## Diagnostics

```bash
./anima doctor
./anima env
./anima url
./anima status
./anima password
```

Reset the generated local desktop password:

```bash
./anima password reset
```

`./anima env` prints the resolved runtime config.
`./anima status` inspects the running container and shows the actual DDS, hardware profile, workspace mount, transport, and Foxglove socket instead of only local defaults.

## Workspace Movement

```bash
./anima import /path/to/workspace.tar.gz
./anima export /path/to/workspace.tar.gz
```

## Demo Package

Seed the named workspace volume with the public starter package:

```bash
./anima demo
```

Then build and run it:

```bash
./anima shell
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 run robotflowlabs_anima_demo hello_anima
```

## Starter Packs

List the bundled starter packs:

```bash
./anima starter list
```

Inspect a starter pack:

```bash
./anima starter show starter-visualization
./anima starter show starter-sim
./anima starter show starter-sensors
```

Install the flagship starter bundle into `/workspaces/anima/src`:

```bash
./anima starter install starter-visualization
```

Install the flagship starter bundle, start its recommended profile, and run it:

```bash
./anima starter run starter-visualization
```

Run the Gazebo starter on the noVNC desktop:

```bash
./anima starter run starter-sim
```

Run the synthetic sensor starter for Foxglove:

```bash
./anima starter run starter-sensors
./anima foxglove dev
```

Run the pack smoke test without touching the active workspace:

```bash
./anima starter test starter-visualization
./anima starter test starter-sim
./anima starter test starter-sensors
```

Remove the installed pack from the workspace:

```bash
./anima starter remove starter-visualization
```

`./anima module ...` remains a legacy alias for the same starter workflow.
`starter-visualization` is the default first-run starter and recommends the `dev` profile.
`starter-sim` is the noVNC-first Gazebo proof path and recommends the `sim` profile.
`starter-sensors` is the Foxglove-first synthetic replay path and recommends the `dev` profile.

## Workspace Modes

Default:

- named Docker volume at `/workspaces/anima`

Optional:

- bind-mounted host workspace with `./anima up --bind ./workspace`

Named volumes are better for Docker Desktop performance. Bind mounts are better when you want immediate host file access.

## DDS And Foxglove

Default DDS:

- Fast DDS / `rmw_fastrtps_cpp`

Optional DDS:

- CycloneDDS / `rmw_cyclonedds_cpp`

Examples:

```bash
./anima up --dds cyclonedds
./anima shell --dds cyclonedds
./anima foxglove dev
```

## Raw Compose Access

If you need direct Compose commands while preserving the env wrapper:

```bash
./anima compose ps
./anima compose logs -f
./anima compose down
```

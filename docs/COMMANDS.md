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
./anima demo
./anima module list
./anima module install starter
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

## Module Bundles

List the bundled workspace modules:

```bash
./anima module list
```

Inspect a module bundle:

```bash
./anima module show starter
```

Install a full starter bundle into `/workspaces/anima/src`:

```bash
./anima module install starter
```

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

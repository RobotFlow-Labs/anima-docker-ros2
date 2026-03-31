# RobotFlowLabs ANIMA Image Matrix

## Supported Distros

- `humble`
- `jazzy`
- `rolling`

## Profiles

### `base`

Includes:

- ROS 2 base image
- colcon
- rosdep
- vcstool
- compiler toolchain
- non-root `ubuntu` user
- Fast DDS and CycloneDDS runtime support

### `desktop`

Includes everything in `base`, plus:

- RViz, RQt, turtlesim, demo nodes, and image tools
- Xfce
- TigerVNC
- noVNC

### `dev`

Includes everything in `desktop`, plus:

- debugging and developer utilities
- terminal multiplexer and CLI tools
- Foxglove bridge

### `sim`

Includes everything in `dev`, plus:

- `ros_gz`
- Foxglove bridge

### `sim-nvidia`

Includes everything in `sim`, plus:

- NVIDIA runtime defaults for Linux/amd64 hosts
- `gpus: all` compose path
- `mesa-utils` and `vulkan-tools` for GPU diagnostics

## Hardware Overlays

These are runtime overlays, not separate image builds.

### `usb`

- privileged USB bus access
- Linux-first passthrough for controllers and vendor devices

### `serial`

- privileged serial device access
- common `/dev/ttyUSB0` and `/dev/ttyACM0` style workflows

### `camera`

- privileged V4L2 camera access
- common `/dev/video0` style workflows

### `audio`

- privileged ALSA device access
- common `/dev/snd` style workflows

### `all`

- merges all four hardware overlays together
- useful for trusted Linux workstations and lab setups

## First Public Defaults

- easiest local run on Mac: `jazzy-desktop`
- easiest developer shell: `jazzy-dev`
- easiest simulation start point: `jazzy-sim`
- easiest NVIDIA simulation start point on Linux: `jazzy-sim-nvidia`
- preferred host architecture: `arm64`
- first-pass hardware overlays: `usb`, `serial`, `camera`, `audio`

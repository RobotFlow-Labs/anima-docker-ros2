# RobotFlowLabs ANIMA Architecture

## Product Direction

RobotFlowLabs ANIMA ROS 2 should behave like a modular robotics developer OS.

It is not a direct fork of a VNC desktop image. The product surface is:

- reproducible ROS 2 environments
- optional remote desktop access
- selectable DDS middleware at runtime
- optional Foxglove bridge access for web-native ROS inspection
- clean layering for developer and simulation needs
- a separate NVIDIA-only simulation path for Linux hosts
- a clear public default around `jazzy-desktop` for the easiest first-run experience
- public OSS docs and CI that validate real usage paths
- bundled starter packs that can be copied into the workspace on demand
- public support, install, and release guidance that makes the default offer obvious

## Layering

### `base`

Purpose:

- shell-first ROS 2 environment
- colcon, rosdep, vcstool, pip, compiler toolchain
- safe default non-root user
- both Fast DDS and CycloneDDS runtime support

### `desktop`

Purpose:

- build on `base`
- remote GUI access via TigerVNC with noVNC as the default browser transport and WebRTC kept as an optional path
- core ROS GUI tools and visualization apps without the full desktop metapackage

### `dev`

Purpose:

- build on `desktop`
- add common developer tooling such as `tmux`, `ripgrep`, editors, and diagnostics
- add Foxglove bridge packages so browser-based robotics tooling is available without a separate image

### `sim`

Purpose:

- build on `dev`
- add Gazebo / `ros_gz` and simulation-oriented packages

### `sim-nvidia`

Purpose:

- build on `sim`
- enable NVIDIA GPU runtime defaults
- keep the Mac and Linux/NVIDIA paths separate so the default desktop experience stays simple

## Build Strategy

Use a single parameterized Dockerfile with named targets and a `docker-bake.hcl` matrix.

Why:

- less distro copy/paste
- easier CI
- parallel target builds
- easier extension for NVIDIA, hardware, and future ANIMA modules

## Standalone Product Policy

This repository should read and behave like a complete standalone product.

That means:

- product docs must stand on their own
- release assets must explain the supported install paths directly
- runtime behavior should not depend on local scratch clones or unmanaged side repositories

## Runtime Layer

The runtime surface is the `./anima` CLI plus the `scripts/` helper layer.

That layer is responsible for:

- selecting the correct env file for the host and profile
- generating local VNC credentials when no explicit password is configured
- mapping host defaults like Docker platform and host OS when env files leave them unset
- choosing named-volume or bind-mounted workspace mode
- selecting DDS middleware without rebuilding the image
- selecting opt-in hardware overlays for USB, serial, camera, and audio without rebuilding the image
- exposing Foxglove on demand for the `dev` and `sim` profiles
- exposing a GPU-enabled sim path for Linux/NVIDIA hosts without changing the Mac default
- installing tracked starter packs into the workspace without rebuilding images

The design goal is to keep the images stable while making the runtime choices late-bound.
Users should not need separate near-duplicate images just to switch DDS or workspace mount mode.

## CI Direction

The current CI verifies:

- every selected target builds
- Compose renders for both named-volume and bind-mounted workspace modes
- the base image can start and source ROS
- the desktop image can start and expose the web UI
- the demo workspace can build with colcon
- the bundled `starter-visualization` pack can build and launch
- CycloneDDS can be selected successfully
- the Foxglove bridge can launch and expose a reachable websocket
- two ROS 2 containers can exchange messages over CycloneDDS
- `rviz2` can start inside the desktop X session without interactive input
- the sim image can resolve and parse a `ros_gz` launch entrypoint
- the branded `./anima up` path can boot and serve the default noVNC desktop
- release assets should include the support matrix and release guide so tagged builds are self-describing

The next phase should add:

- coverage for hardware-aware profiles and a resilient WebRTC path
- a full headless `ros_gz` boot test rather than just launch-file validation
- release measurements and a publish-time support contract that match the supported tags

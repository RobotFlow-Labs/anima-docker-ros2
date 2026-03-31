# RobotFlowLabs ANIMA Mac Quickstart

This is the recommended path for Mac users, especially on Apple Silicon.

## 1. Prerequisites

- Install and start Docker Desktop
- Make sure Docker Desktop has enough resources for a ROS desktop session
- Prefer Apple Silicon if you have the choice

Recommended Docker Desktop settings:

- memory: 8 GB minimum, 12 GB or more for smoother desktop and simulation use
- CPUs: 4 or more
- disk: 40 GB or more free

## 2. Start ANIMA

From the repo root:

```bash
make up
```

Or:

```bash
./anima up
```

Open:

- `http://127.0.0.1:6080`
- optional WebRTC: `./anima up --transport webrtc`

## 3. Use It

Useful commands:

```bash
make up
make up-dev
make up-sim
make doctor
make shell
make demo
make modules
make env
make password
make foxglove
make stop
```

If you want a one-command launcher from the terminal:

```bash
./anima up
```

If you want the raw compose wrapper that still picks the Mac env file automatically:

```bash
./scripts/compose.sh up --build
```

If you want a starter ROS 2 package inside the ANIMA workspace:

```bash
./anima demo
```

If you want the bundled starter module set instead:

```bash
./anima module list
./anima module install starter
```

If you want to work directly against a host folder instead of the default named volume:

```bash
./anima up --bind ./workspace
```

If you want CycloneDDS instead of the default Fast DDS:

```bash
./anima up --dds cyclonedds
```

If you want Foxglove Studio on top of the dev profile:

```bash
./anima foxglove dev
```

If you need USB, serial, camera, or audio passthrough, read [docs/HARDWARE.md](HARDWARE.md) first. Those overlays are Linux-first and best-effort on Docker Desktop for Mac.

If you want to inspect the resolved runtime config before starting:

```bash
./anima env
```

## Default Choices

- distro: `jazzy`
- profile: `desktop`
- hardware: `none`
- workspace: named Docker volume
- access: browser-based desktop
- profile-specific launchers: `make up-dev`, `make up-sim`

## What Works Best

- ROS 2 development
- colcon builds
- browsing docs and running demos
- light-to-moderate GUI tools

## What To Expect

- The first build can take a while because Docker Desktop has to download a full ROS desktop stack.
- Named volumes are faster and simpler than bind mounts on macOS.
- Intel Macs can work, but Apple Silicon is the preferred path.
- This is not a native macOS app; it is a Linux container desktop viewed in the browser.

## Optional Tweaks

If the desktop feels cramped or memory-starved, increase:

- Docker Desktop memory
- Docker Desktop CPUs
- `SHM_SIZE` in `.env`

If you want a different distro or profile, edit `.env`:

- `ROS_DISTRO=humble`
- `ANIMA_PROFILE=dev`
- `VNC_PASSWORD=your-password`
- `ANIMA_DDS_IMPLEMENTATION=cyclonedds`
- `HOST_FOXGLOVE_PORT=8765`
- `ANIMA_HARDWARE_PROFILE=none` unless you know the host can expose devices cleanly

If you do nothing, helper commands on macOS will fall back to:

- `.env.mac` on Apple Silicon
- `.env.intel` on Intel Macs
- the host-specific Mac env file, with the requested profile applied at runtime

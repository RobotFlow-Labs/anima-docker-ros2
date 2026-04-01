# RobotFlowLabs ANIMA Quickstart

## Fastest Path

Prerequisite:

- Docker Desktop running
- Mac users should use [docs/QUICKSTART_MAC.md](QUICKSTART_MAC.md)

Then:

```bash
make up
```

Or use the branded CLI:

```bash
./anima up
```

The startup output now prints:

- the generated local desktop password
- the active DDS implementation
- the workspace mount mode

Open:

- `http://127.0.0.1:6080`
- optional WebRTC: `./anima up --transport webrtc`

For the single flagship starter flow, install the visualization starter and launch it:

```bash
./anima starter install starter-visualization
./anima shell
cd /workspaces/anima
colcon build
source install/setup.bash
ros2 launch robotflowlabs_anima_starter starter_demo.launch.py
```

If you want the published image instead of a local checkout, run:

```bash
docker run --rm \
  -e VNC_PASSWORD=change-me \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 8080:8080 \
  -p 8765:8765 \
  ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-desktop
```

## Optional Helper Commands

```bash
make up
make shell
make stop
make demo
make modules
make env
make password
make foxglove
make up-usb
make up-serial
make up-camera
make up-audio
```

Or:

```bash
./anima up
```

If you want the raw compose entrypoint with the auto-selected env file:

```bash
./scripts/compose.sh up --build
```

If you want profile-specific launchers:

```bash
make up-dev
make up-sim
./anima up dev
./anima up sim
```

If you want the starter ROS 2 package in the named workspace volume:

```bash
./anima demo
```

If you want the bundled starter packs instead:

```bash
./anima starter list
./anima starter install starter-visualization
```

If you want host file access instead of the default named volume:

```bash
./anima up --bind ./workspace
```

If you want CycloneDDS:

```bash
./anima up --dds cyclonedds
```

If you want Foxglove Studio:

```bash
./anima foxglove dev
```

If you need Linux hardware passthrough, opt into one of the overlays:

```bash
./anima up --hardware usb
./anima up --hardware serial
./anima up --hardware camera
./anima up --hardware audio
```

The device-specific notes live in [docs/HARDWARE.md](HARDWARE.md).
If you run the published image directly, set your own password. The checkout flow is the path that auto-generates credentials.

If you want to inspect the resolved runtime config before starting:

```bash
./anima env
```

## Default Runtime Choices

- distro: `jazzy`
- profile: `desktop`
- hardware: `none`
- primary web UI port: `6080`
- optional WebRTC port: `8080`
- VNC port: `5901`
- primary host target: Apple Silicon Mac

## Customize

Copy `.env.example` to `.env` and edit values as needed.

Common changes:

- `ROS_DISTRO=humble`
- `ANIMA_PROFILE=dev`
- `HOST_NOVNC_PORT=7080`
- `HOST_WEBRTC_PORT=8080`
- `VNC_PASSWORD=change-me`
- `ANIMA_DDS_IMPLEMENTATION=cyclonedds`
- `HOST_FOXGLOVE_PORT=8765`
- `SHM_SIZE=2gb` for heavier GUI sessions on Mac
- `ANIMA_HARDWARE_PROFILE=usb|serial|camera|audio|all`

On macOS, helper commands will automatically use `.env.mac` or `.env.intel` unless you create your own `.env`.
On non-mac hosts, profile-specific helpers can use `.env.dev` and `.env.sim`.
Hardware passthrough is Linux-first and should remain opt-in.

## What To Expect On Mac

- Apple Silicon is the first-class path.
- The desktop runs inside Docker Desktop, not as a native macOS app.
- GPU-heavy simulation is possible only within Docker Desktop limits.
- Bind mounts are slower than named volumes on macOS; keep the default volume unless you need host file access.

## Parallel Builds

Build the supported matrix in parallel:

```bash
docker buildx bake
```

Build one target:

```bash
docker buildx bake jazzy-sim
```

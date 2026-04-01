# RobotFlowLabs ANIMA Support Matrix

## Supported Hosts

| Host | Status | Default Offer | Notes |
| --- | --- | --- | --- |
| macOS Apple Silicon | Supported | `jazzy-desktop` | Best first-run path. Uses noVNC by default. |
| macOS Intel | Supported | `jazzy-desktop` | Supported, but slower than Apple Silicon for first builds. |
| Linux x86_64 | Supported | `jazzy-desktop`, `jazzy-dev`, `jazzy-sim` | Best path for hardware overlays and simulation. |
| Linux arm64 | Supported | `jazzy-desktop`, `jazzy-dev`, `jazzy-sim` | Supported where Docker and the target ROS image are available. |
| Linux + NVIDIA | Supported | `jazzy-sim-nvidia` | Requires NVIDIA driver and Container Toolkit on the host. |

## Published Image Targets

| Target | Purpose | Market Use |
| --- | --- | --- |
| `jazzy-desktop` | Desktop ROS 2 starter image | Default public offer |
| `jazzy-dev` | Desktop plus developer tooling | Workspace development and Foxglove |
| `jazzy-sim` | Developer image plus simulation tools | Simulation starter path |
| `jazzy-sim-nvidia` | Simulation image with NVIDIA runtime defaults | Linux GPU workflows |

## Published Distro Tracks

| Distro | Status | Notes |
| --- | --- | --- |
| `humble` | Supported | Stable legacy track for users who need it. |
| `jazzy` | Default | Primary public release track and default market offer. |
| `rolling` | Supported | Moving target for users who want the newest ROS 2 work. |

## Runtime Defaults

- noVNC is the default desktop transport.
- WebRTC remains experimental and should be treated as a preview path.
- Named volumes are the default workspace mode.
- Bind mounts are supported when host file access matters more than Docker Desktop performance.
- Fast DDS is the default middleware, with CycloneDDS available at runtime.

## Hardware Overlay Guidance

These are runtime overlays, not separate image families.

| Overlay | Status | Guidance |
| --- | --- | --- |
| `usb` | Supported | Linux-first. Best for controllers and vendor devices. |
| `serial` | Supported | Linux-first. Best for `/dev/ttyUSB*` and `/dev/ttyACM*`. |
| `camera` | Supported | Linux-first. Best for `/dev/video*`. |
| `audio` | Supported | Linux-first. Best for ALSA device access. |
| `all` | Supported | Only for trusted Linux lab workstations. |

## Known Limits

- The product is not a native macOS application.
- WebRTC is not yet the default transport.
- Hardware passthrough is best supported on Linux hosts.
- Simulation flows require more memory and CPU than the default desktop path.

## How To Choose

- Use `jazzy-desktop` if you want the easiest first success path.
- Use `jazzy-dev` if you want Foxglove and developer tools.
- Use `jazzy-sim` if you want simulation-oriented workflows.
- Use `jazzy-sim-nvidia` only on Linux hosts with working NVIDIA passthrough.
- Use `latest` only when you want the same image as `jazzy-desktop`.

## Related Docs

- [Image Matrix](/Users/ilessio/Development/AIFLOWLABS/projects/ROS2/anima-docker-ros2/docs/IMAGE_MATRIX.md)
- [NVIDIA Path](/Users/ilessio/Development/AIFLOWLABS/projects/ROS2/anima-docker-ros2/docs/NVIDIA.md)
- [Commands](/Users/ilessio/Development/AIFLOWLABS/projects/ROS2/anima-docker-ros2/docs/COMMANDS.md)

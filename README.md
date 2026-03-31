# RobotFlowLabs ANIMA ROS 2

RobotFlowLabs ANIMA ROS 2 is a public, free, open-source ROS 2 developer OS built as a layered container stack rather than a single monolithic desktop image.

The goal is simple:

- fast local onboarding for ROS 2 developers
- modular images for CLI, desktop, dev, and simulation use cases
- parallel multi-target builds with `docker buildx bake`
- a single `./anima` CLI for the common local workflow
- a starter ROS 2 demo package that users can build immediately
- bundled ANIMA workspace modules that can be installed on demand
- generated local desktop credentials instead of a hardcoded default password
- DDS selection and Foxglove bridge support for richer ROS 2 workflows
- opt-in hardware overlays for USB, serial, camera, and audio passthrough
- a clean product repo with local upstream references kept outside the tracked source tree

If you are on a Mac, start with [docs/QUICKSTART_MAC.md](docs/QUICKSTART_MAC.md).
For device passthrough details, see [docs/HARDWARE.md](docs/HARDWARE.md).

If you want to attach with VS Code, use `.devcontainer/` and reopen the repo in a container.
See [docs/DEVCONTAINER.md](docs/DEVCONTAINER.md).

## Community

- Contributing guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Public security guidance: [docs/SECURITY.md](docs/SECURITY.md)
- Command guide: [docs/COMMANDS.md](docs/COMMANDS.md)
- Funding: [.github/FUNDING.yml](.github/FUNDING.yml)
- Issue templates: `.github/ISSUE_TEMPLATE/`

The public issue tracker is for bugs, feature requests, and docs improvements. Security-sensitive reports should follow the private reporting path in the security policy.

## Image Layers

The first scaffold defines four build targets:

- `base`: ROS 2 CLI + colcon/vcstool/rosdep + sane shell defaults
- `desktop`: lightweight remote desktop with noVNC by default, optional WebRTC experiments, and core ROS GUI tools
- `dev`: desktop plus common development tools
- `sim`: dev plus Gazebo / `ros_gz`
- `sim-nvidia`: Linux/NVIDIA sim path with GPU runtime defaults

Supported distro matrix for the initial public pass:

- `humble`
- `jazzy`
- `rolling`

## Quick Start

If Docker Desktop is running, the easiest path is:

```bash
make up
```

That command uses the repo helper layer, auto-selects the right env file on macOS, starts the stack, waits for the web UI, and opens the browser.

That is the default adoption path:

- best experience on Apple Silicon Macs
- no local ROS install
- no local workspace setup
- no manual port wiring
- no extra flags

If you prefer one branded entrypoint instead of Make targets, use:

```bash
./anima up
```

Useful follow-ups:

```bash
./anima status
./anima env
./anima password
./anima demo
./anima module list
./anima module install starter
./anima shell
./anima foxglove dev
./anima up --hardware usb
./anima up --transport webrtc
```

If you want the raw Compose path instead:

```bash
./scripts/compose.sh up --build
```

The helper layer auto-selects:

- `.env.mac` on Apple Silicon Macs
- `.env.intel` on Intel Macs
- `.env.dev` and `.env.sim` for generic non-mac profile helpers
- `.env` if you create a custom override
- `ANIMA_HARDWARE_PROFILE` to opt into USB, serial, camera, or audio overlays

Use `./anima env` to see the fully resolved runtime configuration instead of only the selected env filename.
The default browser URL is the noVNC desktop on `http://127.0.0.1:6080`. WebRTC remains an opt-in best-effort path on `http://127.0.0.1:8080`.

If you want helper commands:

```bash
make up
make shell
make stop
make demo
make password
make foxglove
```

If you want a bind-mounted host workspace instead of the default named volume:

```bash
./anima up --bind ./workspace
```

If you want CycloneDDS instead of Fast DDS:

```bash
./anima up --dds cyclonedds
```

If you want the Mac-specific path:

Open [docs/QUICKSTART_MAC.md](docs/QUICKSTART_MAC.md).

If you are on Linux with an NVIDIA GPU:

```bash
docker compose up --build sim-nvidia
```

To build the GPU matrix:

```bash
docker buildx bake gpu
```

To build the full image matrix in parallel:

```bash
docker buildx bake
```

To build a single target:

```bash
docker buildx bake jazzy-dev
```

Release and image versioning are now driven from [`VERSION`](VERSION). Tagged releases publish multi-arch GHCR images and create a GitHub Release automatically.

## Layout

```text
.
├── .github/
│   ├── FUNDING.yml
│   ├── ISSUE_TEMPLATE/
│   └── workflows/
├── docker/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── start-desktop.sh
├── docs/
│   ├── ARCHITECTURE.md
│   ├── COMMANDS.md
│   └── ROADMAP.md
├── SECURITY.md
├── CONTRIBUTING.md
├── Makefile
├── VERSION
├── scripts/
│   ├── start.sh
│   ├── smoke_demo_workspace.sh
│   └── sync_reference.sh
├── examples/
│   └── robotflowlabs_anima_demo/
├── compose.yaml
└── docker-bake.hcl
```

## Current Status

This repository root is the RobotFlowLabs ANIMA product repo.

The original `Tiryoh/docker-ros2-desktop-vnc` clone is kept locally under `repositories/docker-ros2-desktop-vnc` and stays gitignored. It is a reference implementation, not the tracked source tree.

The current scaffold already includes:

- generated local desktop credentials
- bundled demo and pub/sub starter modules
- named-volume and bind-mounted workspace modes
- Fast DDS and CycloneDDS runtime selection
- Foxglove bridge support on the dev and sim profiles
- GHCR publishing and multi-arch release automation

# RobotFlowLabs ANIMA NVIDIA Path

This path is for Linux hosts with NVIDIA GPUs.

It is intentionally separate from the Mac default.

## What It Gives You

- `sim-nvidia` image target
- `gpus: all` compose runtime
- NVIDIA-oriented environment defaults for OpenGL, Vulkan, and container GPU discovery
- simple GPU diagnostic tools in the image

## What You Need On The Host

- Linux
- NVIDIA driver installed and working
- NVIDIA Container Toolkit installed and configured for Docker

## How To Run

```bash
docker compose up --build sim-nvidia
```

Or build the GPU matrix:

```bash
docker buildx bake gpu
```

## Notes

- The default `desktop` service is still the Mac-first path.
- Do not treat this as a macOS feature. Docker Desktop on Mac is not the target for NVIDIA GPU passthrough here.
- If the host does not expose NVIDIA devices to Docker, the container still builds but GPU acceleration will not activate.

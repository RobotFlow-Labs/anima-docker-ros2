# RobotFlowLabs ANIMA Roadmap

## Completed Foundation

- move upstream reference under `repositories/`
- create ANIMA-native root repo
- define layered Docker build
- wire parallel `buildx bake` targets
- stabilize `humble`, `jazzy`, and `rolling`
- add smoke tests for base and desktop targets
- add smoke tests for multi-container DDS exchange and `rviz2` startup
- publish to GHCR
- document local desktop and CLI workflows
- add a Mac-first quickstart and onboarding path
- add a simple host readiness check for Docker Desktop on Mac
- add generated local credentials
- add ANIMA starter module bundles
- add named-volume and bind-mounted workspace modes
- add DDS presets and Foxglove bridge options
- add opt-in hardware-aware runtime overlays for USB, serial, camera, and audio

## Next Runtime Pass

- add NVIDIA-enabled simulation target
- turn the `ros_gz` launch-file check into a full headless simulation boot test
- improve device autodetection and host-specific guidance for passthrough overlays

## Next Transport Pass

- harden the WebRTC path so it can be promoted from optional to default
- reduce image size and startup latency
- improve Apple Silicon startup time and first-run latency

## Next Product Pass

- education and onboarding profiles
- reproducible demo stacks for public robotics use

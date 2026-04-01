# RobotFlowLabs ANIMA Support Matrix

This matrix is the public support contract for the proof-first starter release.

## Validation Evidence

| Host Class | Validation Surface | Validated On | Default Tag | Evidence |
| --- | --- | --- | --- | --- |
| macOS Apple Silicon | Local source checkout on `arm64` | `2026-04-01` | `jazzy-desktop` | startup timing, image size, starter flows, and Foxglove companion path measured locally |
| macOS Intel | Helper and image contract maintained | `2026-04-01` | `jazzy-desktop` | desktop tag and helper surface remain supported, but Intel startup timing is not benchmarked in this pass |
| Linux x86_64 | CI build and smoke matrix | `2026-04-01` | `jazzy-desktop`, `jazzy-dev`, `jazzy-sim` | compose config, docker build targets, Foxglove smoke, sim smoke, starter smoke jobs, and WebRTC preview smoke are required in CI |
| Linux arm64 | CI build matrix plus shared image contract | `2026-04-01` | `jazzy-desktop`, `jazzy-dev`, `jazzy-sim` | same published tags and starter surface apply where Docker and ROS base images are available |
| Linux + NVIDIA | Publish contract plus sim-nvidia path | `2026-04-01` | `jazzy-sim-nvidia` | NVIDIA path remains Linux-only and requires host driver plus Container Toolkit |

## Measured Public Tags

Measured on the Apple Silicon validation host described in [MEASUREMENTS.md](MEASUREMENTS.md).

| Tag | Startup To Ready | Local arm64 Image Size | Intended Use |
| --- | --- | --- | --- |
| `jazzy-desktop` | `7.2s` | `0.81 GiB` | noVNC-first default desktop path |
| `jazzy-dev` | `5.8s` | `0.83 GiB` | desktop plus developer tools and Foxglove |
| `jazzy-sim` | `5.4s` | `1.03 GiB` | simulation starter path |

## Published Tag Contract

| Tag | Status | Notes |
| --- | --- | --- |
| `jazzy-desktop` | Stable | default public offer |
| `jazzy-dev` | Stable | developer shell plus Foxglove bridge |
| `jazzy-sim` | Stable | simulation-focused public path |
| `jazzy-sim-nvidia` | Stable | Linux + NVIDIA only |
| `latest` | Stable convenience tag | points to the same image as `jazzy-desktop` |
| `v<version>-jazzy-desktop` | Immutable | release-pinned desktop tag |
| `v<version>-jazzy-dev` | Immutable | release-pinned dev tag |
| `v<version>-jazzy-sim` | Immutable | release-pinned sim tag |

## Runtime Defaults

- noVNC is the default desktop transport.
- WebRTC is preview-only in this release surface, but the preview path is still smoke-tested in CI.
- named Docker volumes remain the default workspace mode.
- bind mounts stay supported for host-edit workflows.
- Fast DDS is the default middleware; CycloneDDS is an opt-in runtime flag.

## Starter Coverage

| Starter | Status | Visible Outcome |
| --- | --- | --- |
| `starter-visualization` | Stable | workspace heartbeat plus live ROS 2 pub/sub |
| `starter-sim` | Stable | Gazebo on the noVNC desktop plus `/clock` bridge |
| `starter-sensors` | Stable | deterministic image and lidar-style topics for Foxglove |

## Release Cadence

- semver releases publish multi-arch GHCR images and a GitHub Release
- immutable `v<version>-...` tags define the release contract
- mutable `jazzy-*` tags track the latest stable release for each public surface
- `latest` tracks the current `jazzy-desktop` release

## Known Limits

- this product is still container-first, not a native macOS application
- WebRTC is available only as a preview path and is not the headline support story
- hardware passthrough remains Linux-first
- simulation flows need more memory and CPU than the default desktop path

## Related Docs

- [Measurements](MEASUREMENTS.md)
- [Release Guide](RELEASE_GUIDE.md)
- [Image Matrix](IMAGE_MATRIX.md)
- [Commands](COMMANDS.md)

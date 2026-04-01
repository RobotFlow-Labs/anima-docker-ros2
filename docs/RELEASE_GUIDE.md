# RobotFlowLabs ANIMA Release Guide

## Audience

This guide is for users who want to install ANIMA from published images and for maintainers who cut tagged releases.

## End-User Install Paths

### Source checkout

```bash
make up
```

Or:

```bash
./anima up
```

That path is best when you want to develop from the repo and keep the helper CLI available.

### Published image

Pick the image by use case:

```bash
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-desktop
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-dev
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-sim
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-sim-nvidia
```

Recommended default:

```bash
ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-desktop
```

`latest` points to the same public default as `jazzy-desktop`.

## Tag Selection

- `jazzy-desktop` is the default public offer.
- `jazzy-dev` adds developer tooling and Foxglove.
- `jazzy-sim` adds simulation-oriented packages.
- `jazzy-sim-nvidia` is for Linux hosts with NVIDIA GPU passthrough.
- `latest` is the same image as `jazzy-desktop` and should be treated as the default public path.

## Release Contents

Tagged releases should make it obvious:

- which image tag to use
- which host OS and architecture are supported
- which transport is default
- which features are experimental
- how to install `starter-visualization`

This repository now attaches the release guide and support matrix to the GitHub Release so the public release carries its own install and support contract.

## Maintainer Release Flow

1. Update `VERSION`.
2. Merge the release branch or tag the release commit.
3. Push the tag that matches `VERSION`.
4. Let the publish workflow build and push multi-arch images.
5. Review the GitHub Release notes and attached support assets.

## What To Verify Before Publishing

- `./anima doctor` passes on the target host class.
- `./scripts/smoke_cli_up.sh` passes.
- `./scripts/smoke_modules.sh` passes.
- The support matrix still matches the actual tag and host support.

## Release Notes Contract

Release notes should tell a user:

- what changed
- what image to pull
- what host classes are supported
- what is still experimental

The release notes should not force the reader back into the repository docs to answer those questions.

# RobotFlowLabs ANIMA Release Guide

This guide is the copy-paste install and verification contract for published releases.

## Registry Contract

GHCR is the only supported registry in this phase.

Stable public tags:

- `ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-desktop`
- `ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-dev`
- `ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-sim`
- `ghcr.io/RobotFlow-Labs/anima-ros2:latest` as the convenience alias for `jazzy-desktop`

Immutable release tags:

- `ghcr.io/RobotFlow-Labs/anima-ros2:v<version>-jazzy-desktop`
- `ghcr.io/RobotFlow-Labs/anima-ros2:v<version>-jazzy-dev`
- `ghcr.io/RobotFlow-Labs/anima-ros2:v<version>-jazzy-sim`

## Source Checkout

Use the repo checkout when you want the helper CLI, starter catalog, and local workspace lifecycle:

```bash
make up
```

Or:

```bash
./anima up
```

## Published Image Paths

### `jazzy-desktop`

```bash
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-desktop
docker run --rm \
  -e VNC_PASSWORD=change-me \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 8080:8080 \
  -p 8765:8765 \
  ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-desktop
```

### `jazzy-dev`

```bash
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-dev
docker run --rm \
  -e VNC_PASSWORD=change-me \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 8080:8080 \
  -p 8765:8765 \
  ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-dev \
  desktop
```

### `jazzy-sim`

```bash
docker pull ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-sim
docker run --rm \
  -e VNC_PASSWORD=change-me \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 8080:8080 \
  -p 8765:8765 \
  ghcr.io/RobotFlow-Labs/anima-ros2:jazzy-sim \
  desktop
```

## Starter Flows After Source Checkout

```bash
./anima starter run starter-visualization
./anima foxglove dev
```

```bash
./anima starter run starter-sim
```

```bash
./anima starter run starter-sensors
./anima foxglove dev
```

## Signature Verification

Published releases use Cosign keyless signing through GitHub Actions OIDC.

Install Cosign, then verify a release-pinned tag:

```bash
VERSION=<version>
IMAGE="ghcr.io/RobotFlow-Labs/anima-ros2:v${VERSION}-jazzy-desktop"

cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp 'https://github.com/RobotFlow-Labs/anima-docker-ros2/.github/workflows/publish.yml@refs/tags/v.*' \
  "${IMAGE}"
```

Repeat with `v${VERSION}-jazzy-dev` and `v${VERSION}-jazzy-sim` when you want to verify the full stable set.

## SBOM Artifacts

Each tagged release attaches SPDX JSON SBOM files for the immutable stable tags:

- `v<version>-jazzy-desktop.spdx.json`
- `v<version>-jazzy-dev.spdx.json`
- `v<version>-jazzy-sim.spdx.json`

The release also attaches:

- `INSTALL_CONTRACT.txt`
- `published-digests.txt`
- `docs/SUPPORT_MATRIX.md`
- `docs/RELEASE_GUIDE.md`
- `docs/MEASUREMENTS.md`

Quick local inspection example:

```bash
jq '.packages | length' "v<version>-jazzy-desktop.spdx.json"
```

## Maintainer Release Flow

1. Update `VERSION`.
2. Ensure the starter smoke jobs and compose validation pass.
3. Tag the release commit with `v<VERSION>`.
4. Push the tag.
5. Let the publish workflow push images, generate SBOMs, sign stable digests, and attach release artifacts.
6. Confirm the release page exposes the install contract, digests, support matrix, release guide, and SBOMs.

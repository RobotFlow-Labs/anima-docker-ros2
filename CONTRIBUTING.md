# Contributing to RobotFlowLabs ANIMA

RobotFlowLabs ANIMA is an open public project. The goal is to keep the repo easy to adopt, easy to review, and easy to maintain.

## Local Policy

The tracked root is the RobotFlowLabs ANIMA repo.

Third-party reference repos belong under `repositories/` and stay gitignored.

Current local reference:

- `repositories/docker-ros2-desktop-vnc`

## Local Build

```bash
make up
```

If you want the raw Compose path:

```bash
./scripts/compose.sh up --build
```

Or build the matrix in parallel:

```bash
docker buildx bake
```

## Local Smoke Tests

```bash
./scripts/smoke_base.sh jazzy
./scripts/smoke_desktop.sh jazzy
./scripts/smoke_sim.sh jazzy
```

## Scope

Prefer:

- shared build logic
- layered images
- current supported ROS 2 distros
- small runtime scripts

Avoid:

- per-distro Dockerfile duplication
- per-distro workflow duplication
- hidden local assumptions in the default run path

## Before Opening an Issue or PR

- use `make doctor`
- reproduce on the smallest relevant profile
- include the ROS 2 distro and host platform
- use the GitHub issue templates when filing public issues
- keep security-sensitive reports out of public issues
- link the related issue in the pull request when possible
- include logs for desktop or build failures

## Public Repo Expectations

- keep the default path simple for first-time users
- preserve Mac-first onboarding
- prefer layered build targets over one-off runtime hacks
- keep docs aligned with actual commands

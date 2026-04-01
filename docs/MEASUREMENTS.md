# RobotFlowLabs ANIMA Measurements

This document is the source of truth for the benchmark numbers summarized in the README and support matrix.

## Validation Host

- date: `2026-04-01`
- host class: `macOS Apple Silicon`
- OS: `macOS 26.3`
- architecture: `arm64`
- repo mode: local source checkout

## Method

Startup-to-ready measurements:

1. run `./scripts/compose.sh down -v`
2. run `./anima up <profile> --no-open`
3. record wall-clock time until the helper exits successfully
4. tear the stack down before the next profile

Foxglove companion measurements:

1. start the matching `dev` or `sim` profile first
2. run `./anima foxglove <profile> --no-open`
3. record wall-clock time until the websocket is reported ready

Image sizes:

1. inspect local arm64 images with `docker image inspect`
2. report the uncompressed size returned by Docker

## Startup To Ready

| Tag | Command | Result |
| --- | --- | --- |
| `jazzy-desktop` | `./anima up desktop --no-open` | `7.2s` |
| `jazzy-dev` | `./anima up dev --no-open` | `5.8s` |
| `jazzy-sim` | `./anima up sim --no-open` | `5.4s` |

## Foxglove Companion

| Profile | Command | Result |
| --- | --- | --- |
| `dev` | `./anima foxglove dev --no-open` | `0.5s` |
| `sim` | `./anima foxglove sim --no-open` | `0.5s` |

## Local arm64 Image Sizes

| Tag | Bytes | Human |
| --- | --- | --- |
| `jazzy-desktop` | `873782772` | `0.81 GiB` |
| `jazzy-dev` | `887508335` | `0.83 GiB` |
| `jazzy-sim` | `1101099577` | `1.03 GiB` |

## Notes

- these are local Apple Silicon results, not universal guarantees
- Linux smoke validation is enforced in CI, but Linux startup timing is not benchmarked in this pass
- refresh this document when the desktop stack, starter catalog, or image composition changes materially

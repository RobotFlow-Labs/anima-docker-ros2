# RobotFlowLabs ANIMA Starter Product Plan

## Purpose

This repository should evolve into a market-facing ROS 2 starter product that is adjacent to ANIMA, but not dependent on the broader ANIMA module ecosystem to deliver immediate value.

The product goal is:

- the fastest reliable way to start ROS 2 on macOS and Linux without a local ROS install
- a noVNC-first remote ROS 2 desktop that works on day one
- a curated starter experience with visible outcomes, not just a desktop container
- a modular upgrade path into richer RobotFlowLabs and ANIMA workflows later

This is a starter product, not the full ANIMA platform.

## Product Position

The cloned benchmark in `repositories/docker-ros2-desktop-vnc` is a strong reference for:

- simplicity
- public trust
- obvious first-run behavior

This repo should beat it by combining:

- easier onboarding on Apple Silicon
- layered targets instead of a monolithic image
- starter packs with actual ROS 2 outcomes
- Foxglove and DDS switching
- workspace movement and hardware-aware overlays

## Non-Goals

Out of scope for this starter product:

- full ANIMA module registry and compiler integration
- deep ANIMA manifests and orchestration workflows
- enterprise fleet management
- hosted services
- making WebRTC the default before it is stable

If a feature only matters once the user is already inside the wider ANIMA platform, it should remain out of scope for this repo.

## Current Gaps

The repo is technically ahead of the cloned benchmark, but not yet market-ready because:

- starter modules are smoke-test assets, not outcome-driven starter packs
- onboarding is repo-centric instead of install-and-win-centric
- module bundles are local/internal, not productized
- README and quickstarts describe capabilities but not a sharp market offer
- public trust signals are weaker than the benchmark
- comparison, migration, and launch assets are missing

## Product Strategy

Ship this product in four tracks:

1. Onboarding and positioning
2. Module system productization
3. Outcome-driven starter packs
4. Distribution, trust, and market comparison

## Release Principle

The product only goes to market when a new user can:

1. start the desktop with one command
2. open one URL
3. install one starter pack
4. see one meaningful robotics workflow complete in under 10 minutes

## Workstream A: Onboarding and Positioning

Goal:

- make the product instantly understandable and easy to adopt

Deliverables:

- sharpened README hero section and product tagline
- explicit ICP and use-case framing
- canonical install paths:
  - source checkout path
  - image-first path from GHCR
- revised quickstart optimized for first success
- first-10-minutes walkthrough with screenshots and expected outputs
- migration/comparison page against `docker-ros2-desktop-vnc`

Acceptance criteria:

- the top of the README explains what this product is in under 3 lines
- the first successful path does not require reading architecture docs
- the benchmark comparison is explicit and favorable on differentiated features

## Workstream B: Module System Productization

Goal:

- turn starter bundles into a product surface rather than an internal copy helper

Deliverables:

- starter pack manifest spec
- richer metadata:
  - id
  - title
  - version
  - summary
  - supported distros
  - supported profiles
  - dependencies
  - install targets
  - next step command
  - smoke test command
- CLI evolution:
  - `./anima starter list`
  - `./anima starter show <id>`
  - `./anima starter install <id>`
  - `./anima starter remove <id>`
  - `./anima starter test <id>`
- compatibility validation and better errors

Acceptance criteria:

- starter packs are discoverable and self-describing
- install/remove/test are symmetric and safe
- unsupported distro/profile combinations fail early with actionable guidance

## Workstream C: Outcome-Driven Starter Packs

Goal:

- replace generic smoke modules with real “jobs to be done”

Priority starter packs:

- `starter-visualization`
  - build a workspace
  - run a ROS 2 publisher/subscriber
  - expose state in Foxglove or a clear desktop GUI flow
- `starter-sim`
  - launch a reproducible simulation-oriented demo
  - validate GUI and ROS graph together
- `starter-sensors`
  - prepare a replay-first sensor workflow using recorded data
  - keep live hardware optional

Rules:

- replay/mock-first, hardware-second
- every starter pack must produce a visible success condition
- packs must work in the supported default target before advanced targets

Acceptance criteria:

- each starter pack has a README, install command, run command, and smoke test
- each pack completes in a beginner-friendly sequence
- at least one starter pack is strong enough to be the default marketing demo

## Workstream D: Distribution, Trust, and Market Readiness

Goal:

- make the product look and behave like something users can trust

Deliverables:

- release positioning around `jazzy-desktop` as the default offer
- support matrix for:
  - Apple Silicon macOS
  - Intel macOS
  - Linux desktop
- startup time and image-size benchmarks
- public release notes template
- README trust assets:
  - screenshots
  - animated demo
  - support matrix
  - feature comparison table
- stronger publish/install docs for GHCR

Acceptance criteria:

- the user can identify which image/tag to use without reading the whole repo
- screenshots and comparison assets exist in-tree
- there is a clear answer to “why use this instead of the cloned benchmark?”

## Execution Order

### Phase 1: Position the product

- rewrite README hero and quickstart around one default starter workflow
- add comparison and migration docs
- keep scope explicitly “starter product”

### Phase 2: Productize starter bundles

- define manifest shape
- evolve CLI from module helper to starter product interface
- retain backward compatibility where cheap

### Phase 3: Ship real starter packs

- promote one pack as the canonical demo
- add pack-specific smoke tests
- update CI around starter pack validity

### Phase 4: Ship the public launch surface

- screenshots, benchmarks, support matrix
- release notes and install docs
- comparison assets and distribution polish

## Candidate Default Offer

The most promising first market message is:

`The fastest ROS 2 starter desktop for Mac and Linux, with one-command setup and real starter workflows.`

The most promising default starter experience is:

- `./anima up`
- `./anima starter install visualization`
- `./anima foxglove dev`

That path should become the flagship demo once the visualization starter pack is ready.

## Subagent Ownership

Agent 1 owns:

- README hero
- quickstart restructuring
- comparison and migration docs

Agent 2 owns:

- starter manifest design
- CLI command surface proposal
- compatibility and lifecycle behavior

Agent 3 owns:

- starter pack definitions
- workspace package/demo layout
- smoke-test strategy for starter packs

Agent 4 owns:

- market-readiness surface
- screenshots/assets/support matrix
- publish/install/release trust improvements

## Definition of Done

This repo is market-ready as a starter product when:

- the README has a clear market message and one-command onboarding
- starter packs are productized, not just copied into the workspace
- at least one starter pack delivers a meaningful robotics workflow
- CI validates the flagship starter flow
- the benchmark comparison is explicit and favorable
- the repo can be recommended publicly without explaining ANIMA first

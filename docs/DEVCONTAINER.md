# RobotFlowLabs ANIMA Devcontainer

If you prefer editor attachment over the browser desktop, use the devcontainer in [`.devcontainer/devcontainer.json`](/Users/ilessio/Development/AIFLOWLABS/projects/ROS2/anima-docker-ros2/.devcontainer/devcontainer.json).

## Intended Use

- Mac developers using VS Code or compatible editors
- Apple Silicon friendly developer workflow
- bind-mounted source tree with a persistent container home volume

## What It Does

- builds the `dev` target from `docker/Dockerfile`
- mounts this repo into `/workspaces/anima/src/robotflowlabs-anima`
- keeps the rest of the ANIMA workspace behavior intact
- installs a useful baseline extension set for ROS-adjacent development

## When To Use It

Use the devcontainer when:

- you want editor autocomplete and debugger integration
- you are editing this repo itself
- you do not need the browser desktop as your primary interface

Use the browser desktop when:

- you want the simplest no-install experience
- you want GUI ROS tools exposed immediately

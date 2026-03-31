# RobotFlowLabs ANIMA Security

## Current Defaults

- container user defaults to non-root `ubuntu`
- noVNC is exposed on port `6080`
- VNC is exposed on port `5901`
- Foxglove bridge can be exposed on port `8765` when the dev or sim profile starts it
- the default Mac path uses Docker Desktop, which is a shared desktop/runtime environment rather than a hardened appliance

## Important Notes

- The helper layer now generates a local VNC password automatically when you do not set one explicitly.
- Use `./anima password` to inspect the generated credential and `./anima password reset` to rotate it.
- If you set `VNC_PASSWORD` in your env file, that explicit value overrides the generated local secret.
- This repository intentionally avoids patching the noVNC UI with a hardcoded plaintext password.
- On Mac, named volumes are safer and faster than bind mounts for the default workspace path.

## Hardware Passthrough

When enabling:

- USB devices
- serial devices
- cameras
- audio
- GPU acceleration

review the Docker runtime permissions carefully. Those should remain opt-in profiles, not default behavior.

The current first pass uses compose overlays that enable the relevant device access path at runtime. They are intentionally not baked into the image because the safe default for Mac users is still `none`.

Practical guidance:

- treat these as trusted-host profiles
- prefer Linux hosts for real device access
- use `./anima doctor` before enabling a hardware profile
- keep the default named-volume workflow when you do not need the device node on the host

## Future Hardening

- add a WebRTC transport path
- add smoke tests that verify the desktop comes up without privileged container assumptions
- expand security guidance for Foxglove and DDS network exposure

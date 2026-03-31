# RobotFlowLabs ANIMA Hardware Profiles

ANIMA keeps hardware passthrough opt-in. The default experience is still `none`, which is the safest path for macOS and the least surprising path for Docker Desktop users.

## Profiles

### `none`

Default runtime. No extra device exposure.

### `usb`

Best for USB peripherals such as microcontrollers, adapters, and some vendor SDK devices on Linux hosts.

Example:

```bash
./anima up --hardware usb
```

### `serial`

Best for serial-attached boards and sensors that appear as `/dev/ttyUSB0` or `/dev/ttyACM0` on Linux.

Example:

```bash
./anima up --hardware serial
```

If your device uses a different node, override it with:

```bash
ANIMA_SERIAL_DEVICE=/dev/ttyACM0 ./anima up --hardware serial
```

### `camera`

Best for V4L2-style camera devices such as `/dev/video0`.

Example:

```bash
./anima up --hardware camera
```

### `audio`

Best for ALSA-style audio devices such as `/dev/snd`.

Example:

```bash
./anima up --hardware audio
```

### `all`

Enables every first-pass overlay at once.

Example:

```bash
./anima up --hardware all
```

## Safety Notes

- These profiles are trusted-host overlays, not sandboxing features.
- They are best supported on Linux hosts.
- Docker Desktop on macOS may not expose the underlying device nodes directly, even when the container starts successfully.
- Use `./anima doctor` before enabling a hardware profile to check for missing device nodes and busy ports.

## Runtime Files

The hardware overlays live at the repo root:

- `compose.hardware.usb.yaml`
- `compose.hardware.serial.yaml`
- `compose.hardware.camera.yaml`
- `compose.hardware.audio.yaml`

The `./anima` CLI and `Makefile` wrappers map these overlays automatically.

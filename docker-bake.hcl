variable "REGISTRY_PREFIX" {
  default = "ghcr.io/RobotFlow-Labs/anima-ros2"
}

variable "VERSION" {
  default = "0.1.0"
}

variable "REVISION" {
  default = "dev"
}

variable "BUILD_DATE" {
  default = "1970-01-01T00:00:00Z"
}

target "common" {
  context = "."
  dockerfile = "docker/Dockerfile"
  pull = true
  labels = {
    "org.opencontainers.image.title" = "RobotFlowLabs ANIMA ROS 2"
    "org.opencontainers.image.description" = "RobotFlowLabs ANIMA ROS 2 layered container stack"
    "org.opencontainers.image.vendor" = "RobotFlowLabs"
    "org.opencontainers.image.source" = "https://github.com/RobotFlow-Labs/anima-docker-ros2"
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.version" = "${VERSION}"
    "org.opencontainers.image.revision" = "${REVISION}"
    "org.opencontainers.image.created" = "${BUILD_DATE}"
  }
}

group "default" {
  targets = [
    "humble-base",
    "humble-desktop",
    "humble-dev",
    "humble-sim",
    "jazzy-base",
    "jazzy-desktop",
    "jazzy-dev",
    "jazzy-sim",
    "rolling-base",
    "rolling-desktop",
    "rolling-dev",
    "rolling-sim",
  ]
}

group "stable" {
  targets = [
    "jazzy-base",
    "jazzy-desktop",
    "jazzy-dev",
    "jazzy-sim",
  ]
}

group "gpu" {
  targets = [
    "humble-sim-nvidia",
    "jazzy-sim-nvidia",
    "rolling-sim-nvidia",
  ]
}

target "humble-base" {
  inherits = ["common"]
  target = "base"
  args = { ROS_DISTRO = "humble" }
  tags = [
    "${REGISTRY_PREFIX}:humble-base",
    "${REGISTRY_PREFIX}:v${VERSION}-humble-base",
  ]
}

target "humble-desktop" {
  inherits = ["common"]
  target = "desktop"
  args = { ROS_DISTRO = "humble" }
  tags = [
    "${REGISTRY_PREFIX}:humble-desktop",
    "${REGISTRY_PREFIX}:v${VERSION}-humble-desktop",
  ]
}

target "humble-dev" {
  inherits = ["common"]
  target = "dev"
  args = { ROS_DISTRO = "humble" }
  tags = [
    "${REGISTRY_PREFIX}:humble-dev",
    "${REGISTRY_PREFIX}:v${VERSION}-humble-dev",
  ]
}

target "humble-sim" {
  inherits = ["common"]
  target = "sim"
  args = { ROS_DISTRO = "humble" }
  tags = [
    "${REGISTRY_PREFIX}:humble-sim",
    "${REGISTRY_PREFIX}:v${VERSION}-humble-sim",
  ]
}

target "humble-sim-nvidia" {
  inherits = ["common"]
  target = "sim-nvidia"
  args = { ROS_DISTRO = "humble" }
  tags = [
    "${REGISTRY_PREFIX}:humble-sim-nvidia",
    "${REGISTRY_PREFIX}:v${VERSION}-humble-sim-nvidia",
  ]
}

target "jazzy-base" {
  inherits = ["common"]
  target = "base"
  args = { ROS_DISTRO = "jazzy" }
  tags = [
    "${REGISTRY_PREFIX}:jazzy-base",
    "${REGISTRY_PREFIX}:v${VERSION}-jazzy-base",
  ]
}

target "jazzy-desktop" {
  inherits = ["common"]
  target = "desktop"
  args = { ROS_DISTRO = "jazzy" }
  tags = [
    "${REGISTRY_PREFIX}:jazzy-desktop",
    "${REGISTRY_PREFIX}:latest",
    "${REGISTRY_PREFIX}:v${VERSION}-jazzy-desktop",
  ]
}

target "jazzy-dev" {
  inherits = ["common"]
  target = "dev"
  args = { ROS_DISTRO = "jazzy" }
  tags = [
    "${REGISTRY_PREFIX}:jazzy-dev",
    "${REGISTRY_PREFIX}:v${VERSION}-jazzy-dev",
  ]
}

target "jazzy-sim" {
  inherits = ["common"]
  target = "sim"
  args = { ROS_DISTRO = "jazzy" }
  tags = [
    "${REGISTRY_PREFIX}:jazzy-sim",
    "${REGISTRY_PREFIX}:v${VERSION}-jazzy-sim",
  ]
}

target "jazzy-sim-nvidia" {
  inherits = ["common"]
  target = "sim-nvidia"
  args = { ROS_DISTRO = "jazzy" }
  tags = [
    "${REGISTRY_PREFIX}:jazzy-sim-nvidia",
    "${REGISTRY_PREFIX}:v${VERSION}-jazzy-sim-nvidia",
  ]
}

target "rolling-base" {
  inherits = ["common"]
  target = "base"
  args = { ROS_DISTRO = "rolling" }
  tags = [
    "${REGISTRY_PREFIX}:rolling-base",
    "${REGISTRY_PREFIX}:v${VERSION}-rolling-base",
  ]
}

target "rolling-desktop" {
  inherits = ["common"]
  target = "desktop"
  args = { ROS_DISTRO = "rolling" }
  tags = [
    "${REGISTRY_PREFIX}:rolling-desktop",
    "${REGISTRY_PREFIX}:v${VERSION}-rolling-desktop",
  ]
}

target "rolling-dev" {
  inherits = ["common"]
  target = "dev"
  args = { ROS_DISTRO = "rolling" }
  tags = [
    "${REGISTRY_PREFIX}:rolling-dev",
    "${REGISTRY_PREFIX}:v${VERSION}-rolling-dev",
  ]
}

target "rolling-sim" {
  inherits = ["common"]
  target = "sim"
  args = { ROS_DISTRO = "rolling" }
  tags = [
    "${REGISTRY_PREFIX}:rolling-sim",
    "${REGISTRY_PREFIX}:v${VERSION}-rolling-sim",
  ]
}

target "rolling-sim-nvidia" {
  inherits = ["common"]
  target = "sim-nvidia"
  args = { ROS_DISTRO = "rolling" }
  tags = [
    "${REGISTRY_PREFIX}:rolling-sim-nvidia",
    "${REGISTRY_PREFIX}:v${VERSION}-rolling-sim-nvidia",
  ]
}

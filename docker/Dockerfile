# syntax=docker/dockerfile:1.7

ARG ROS_DISTRO=jazzy
ARG SELKIES_TAG=v1.6.2
ARG SELKIES_VERSION=1.6.2

FROM ros:${ROS_DISTRO}-ros-base AS base
ARG ROS_DISTRO
SHELL ["/bin/bash", "-lc"]

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=${ROS_DISTRO}
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ANIMA_WS=/workspaces/anima

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    git \
    gosu \
    locales \
    lsb-release \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    python3-vcstool \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ripgrep \
    sudo \
    tini \
    tmux \
    tzdata \
    vim && \
    locale-gen en_US.UTF-8 && \
    rosdep init 2>/dev/null || true && \
    rm -rf /var/lib/apt/lists/*

RUN rosdep update || true

RUN id -u ubuntu >/dev/null 2>&1 || useradd --create-home --shell /bin/bash ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    mkdir -p ${ANIMA_WS}/src && \
    chown -R ubuntu:ubuntu /home/ubuntu /workspaces

COPY docker/entrypoint.sh /usr/local/bin/anima-entrypoint
COPY docker/bootstrap-workspace.sh /usr/local/bin/anima-bootstrap
RUN chmod +x /usr/local/bin/anima-entrypoint /usr/local/bin/anima-bootstrap

WORKDIR ${ANIMA_WS}
USER ubuntu
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/anima-entrypoint"]
CMD ["bash"]

FROM base AS desktop
ARG ROS_DISTRO
ARG SELKIES_TAG
ARG SELKIES_VERSION
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    gstreamer1.0-gl \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gir1.2-gst-plugins-bad-1.0 \
    gir1.2-gst-plugins-base-1.0 \
    gir1.2-gstreamer-1.0 \
    novnc \
    pulseaudio \
    python3-websockify \
    python3-gi \
    python3-gi-cairo \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-terminal \
    xauth \
    x11-xserver-utils \
    xdg-desktop-portal \
    xsel \
    dbus-x11 \
    ros-${ROS_DISTRO}-demo-nodes-cpp \
    ros-${ROS_DISTRO}-demo-nodes-py \
    ros-${ROS_DISTRO}-image-tools \
    ros-${ROS_DISTRO}-rqt \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-turtlesim && \
    curl -fsSLo /tmp/selkies.whl "https://github.com/selkies-project/selkies-gstreamer/releases/download/${SELKIES_TAG}/selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && \
    curl -fsSLo /tmp/gst-web.tar.gz "https://github.com/selkies-project/selkies-gstreamer/releases/download/${SELKIES_TAG}/selkies-gstreamer-web_${SELKIES_TAG}.tar.gz" && \
    python3 -m pip install --no-cache-dir /tmp/selkies.whl && \
    mkdir -p /opt && \
    tar -xzf /tmp/gst-web.tar.gz -C /opt && \
    rm -f /tmp/selkies.whl /tmp/gst-web.tar.gz && \
    rm -rf /var/lib/apt/lists/*

COPY docker/start-desktop.sh /usr/local/bin/anima-desktop
RUN chmod +x /usr/local/bin/anima-desktop && \
    chown ubuntu:ubuntu /usr/local/bin/anima-desktop

EXPOSE 5901 6080 8080 8765
USER ubuntu
CMD ["desktop"]

FROM desktop AS dev
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    gdb \
    htop \
    iputils-ping \
    net-tools \
    ros-${ROS_DISTRO}-foxglove-bridge \
    tree && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu
CMD ["bash"]

FROM dev AS sim
ARG ROS_DISTRO
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-ros-gz && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu
CMD ["bash"]

FROM sim AS sim-nvidia
ARG ROS_DISTRO
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    mesa-utils \
    vulkan-tools && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/anima/runtime.d && \
    cat > /etc/anima/runtime.d/90-nvidia.sh <<'EOF'
#!/usr/bin/env bash

export ANIMA_ENABLE_NVIDIA="${ANIMA_ENABLE_NVIDIA:-true}"
export NVIDIA_VISIBLE_DEVICES="${NVIDIA_VISIBLE_DEVICES:-all}"
export NVIDIA_DRIVER_CAPABILITIES="${NVIDIA_DRIVER_CAPABILITIES:-compute,utility,graphics,video}"
export __GLX_VENDOR_LIBRARY_NAME="${__GLX_VENDOR_LIBRARY_NAME:-nvidia}"
export __NV_PRIME_RENDER_OFFLOAD="${__NV_PRIME_RENDER_OFFLOAD:-1}"
export __VK_LAYER_NV_optimus="${__VK_LAYER_NV_optimus:-NVIDIA_only}"
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-0}"
EOF

USER ubuntu
CMD ["bash"]

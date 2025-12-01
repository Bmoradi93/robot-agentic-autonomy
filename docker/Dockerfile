# Base image
FROM osrf/ros:humble-desktop

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Basic Dependencies & Tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    wget \
    curl \
    iputils-ping \
    nano \
    vim \
    tmux \
    udev \
    usbutils \
    software-properties-common \
    # ROS packages
    ros-humble-irobot-create-msgs \
    ros-humble-irobot-create-nodes \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-diagnostic-updater \
    ros-humble-diagnostic-msgs \
    ros-humble-laser-proc \
    ros-humble-foxglove-bridge && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup Intel RealSense Repo & Install Pinned Version (L515 Support)
# We accept the key, add the repo, and install specific version 2.54.2
# REMOVED: librealsense2-dkms (Cannot install kernel modules in Docker)
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/librealsense.list && \
    apt-get update && \
    apt-get install -y \
    librealsense2=2.54.2-0~realsense.10773 \
    librealsense2-gl=2.54.2-0~realsense.10773 \
    librealsense2-utils=2.54.2-0~realsense.10773 \
    librealsense2-dev=2.54.2-0~realsense.10773 && \
    apt-mark hold librealsense2 librealsense2-gl librealsense2-utils librealsense2-dev && \
    rm -rf /var/lib/apt/lists/*

# Install RealSense udev rules
RUN wget https://raw.githubusercontent.com/IntelRealSense/librealsense/master/config/99-realsense-libusb.rules -O /etc/udev/rules.d/99-realsense-libusb.rules

# Create a non-root user
ENV USERNAME=ros
RUN addgroup --gid 1000 ${USERNAME} && \
    adduser --disabled-password --gecos "" --shell /bin/bash --uid 1000 --gid 1000 ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    usermod -aG sudo,dialout,video,plugdev ${USERNAME}

# Set up user's home directory
RUN mkdir -p /home/${USERNAME}/.ros && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Switch to the non-root user
USER ${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR /home/${USERNAME}

# === FIX: Change shell to bash so 'source' works ===
SHELL ["/bin/bash", "-c"]

# 3. Build realsense-ros from source
# RUN mkdir -p /home/${USERNAME}/ros2_ws/src && \
#     cd /home/${USERNAME}/ros2_ws/src && \
#     git clone https://github.com/IntelRealSense/realsense-ros.git -b ros2-development && \
#     cd /home/${USERNAME}/ros2_ws && \
#     source /opt/ros/humble/setup.bash && \
#     rosdep update && \
#     rosdep install -i --from-path src --rosdistro humble --skip-keys=librealsense2 -y && \
#     colcon build --symlink-install

# Source ROS setup script
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${USERNAME}/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /home/${USERNAME}/.bashrc
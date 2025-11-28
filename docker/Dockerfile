# Base image
FROM osrf/ros:humble-desktop

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
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
    # ROS packages
    ros-humble-irobot-create-msgs \
    ros-humble-irobot-create-nodes \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-foxglove-bridge && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
ENV USERNAME=ros
RUN addgroup --gid 1000 ${USERNAME} && \
    adduser --disabled-password --gecos "" --shell /bin/bash --uid 1000 --gid 1000 ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    usermod -aG sudo ${USERNAME}

# Set up user's home directory
RUN mkdir -p /home/${USERNAME}/.ros && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Switch to the non-root user
USER ${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR /home/${USERNAME}

# Source ROS setup script
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${USERNAME}/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /home/${USERNAME}/.bashrc

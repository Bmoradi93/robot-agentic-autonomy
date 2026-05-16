# AGENTS.md

Compact instructions for OpenCode sessions working on this TurtleBot4 ROS 2 Humble development environment.

## Repository Structure

- `ros2_ws/src/` – ROS 2 workspace with git submodules (TurtleBot4, RealSense, URG node)
- `docker/` – Dockerfile and config for `turtlebot4-dev` image
- `Makefile` – Docker orchestration and connection management
- `dependencies.repos` – vcstool manifest for additional dependencies
- `.gitmodules` – 6 git submodules for ROS packages

## Critical Setup Requirements

**Before building or running code:**

```bash
git submodule update --init --recursive
```

The workspace depends on 6 git submodules. They are tracked but not initialized by default. Missing this step breaks all builds.

## Development Workflow

All development happens **inside Docker**. The workspace is mounted at `/workspace/robot-agentic-autonomy` in the container.

### Standard Commands

```bash
make build          # Build Docker image (first time or after Dockerfile changes)
make start          # Start container in background
make enter          # Interactive shell with ROS env configured
make stop           # Stop and remove container
```

### Connection Methods

`make enter` prompts for connection type:

1. **Wi-Fi (Discovery Server)** – requires `make discovery-server` running on host
2. **Direct LAN/USB-C** – robot at `192.168.186.2`, host at `192.168.186.3/24`

Both set `RMW_IMPLEMENTATION=rmw_cyclonedds_cpp` and `ROS_DISCOVERY_SERVER` automatically.

## Known Build Issues

### GPIOD Library Linking Error

If `turtlebot4_base` fails with:
```
/usr/bin/ld: cannot find -lgpiod_library-NOTFOUND
```

Fix in `ros2_ws/src/turtlebot4_robot/turtlebot4_base/CMakeLists.txt`:

**Replace:**
```cmake
find_library(gpiod_library NAMES libgpiod.so)
target_link_libraries(${PROJECT_NAME}_lib ${gpiod_library})
```

**With:**
```cmake
find_package(PkgConfig REQUIRED)
pkg_check_modules(GPIOD REQUIRED libgpiod)
target_link_libraries(${PROJECT_NAME}_lib ${GPIOD_LIBRARIES})
target_include_directories(${PROJECT_NAME}_lib PRIVATE ${GPIOD_INCLUDE_DIRS})
```

This is documented in README.md:107-136.

## Dependencies

- ROS 2 Humble from `osrf/ros:humble-desktop`
- CycloneDDS middleware (required by TurtleBot4 firmware)
- Intel RealSense 2.54.2 (pinned for L515 support)
- Ignition Fortress simulator
- Additional packages pulled via `dependencies.repos` (create3_sim, irobot_create_msgs)

## ROS Workspace Build

Inside container:

```bash
cd /workspace/robot-agentic-autonomy/ros2_ws
source /opt/ros/humble/setup.bash
rosdep update
rosdep install -i --from-path src --rosdistro humble --skip-keys=librealsense2 -y
colcon build --symlink-install
source install/setup.bash
```

## Network Configuration

- Wi-Fi: Laptop runs discovery server on port 11811, robot configured via web UI
- LAN/USB-C: Static link-local network `192.168.186.0/24`
  - Robot: `192.168.186.2`
  - Host: `192.168.186.3` (set via `scripts/set_ip.sh <interface>`)

Verify LAN connection: `make ping-robot-lan`

## Container Details

- Name: `turtlebot4-container`
- Image: `turtlebot4-dev`
- Mounts: `/dev`, `/tmp/.X-unix`, workspace at `/workspace/robot-agentic-autonomy`
- Network: `--net=host` for ROS 2 communication
- Privileged: USB device access for RealSense/LIDAR

## Environment Variables (Set in Container)

- `RMW_IMPLEMENTATION=rmw_cyclonedds_cpp` (always)
- `ROS_DISCOVERY_SERVER` (set by `make enter` based on connection method)

## Testing Robot Connection

```bash
ros2 topic list
ros2 topic echo /odom
```

Expected topics: `/cmd_vel`, `/odom`, `/scan`, `/battery_state`, etc.

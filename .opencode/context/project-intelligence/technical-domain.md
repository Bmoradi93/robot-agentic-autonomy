<!-- Context: project-intelligence/technical | Priority: critical | Version: 1.0 | Updated: 2026-05-16 -->

# Technical Domain: TurtleBot4 ROS 2 Development

**Purpose**: Tech stack, architecture, and development patterns for TurtleBot4 robotics development.
**Last Updated**: 2026-05-16
**Update Triggers**: Tech stack changes | ROS packages | Build system | Hardware changes

## Primary Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| ROS | ROS 2 Humble (humble-desktop) | LTS release, TurtleBot4 compatible |
| Middleware | CycloneDDS (rmw_cyclonedds_cpp) | Required by TurtleBot4 firmware |
| Build | colcon + CMake | ROS 2 standard |
| Container | Docker (osrf/ros:humble-desktop) | Isolated dev environment |
| Simulator | Ignition Fortress | Gazebo successor |
| Languages | C++17, Python 3.10 | ROS 2 Humble defaults |
| Hardware | TurtleBot4, RealSense L515, URG LIDAR | See AGENTS.md for setup |

## Development Patterns

### Python ROS 2 Node Pattern

```python
import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class MyNode(Node):
    def __init__(self):
        super().__init__('my_node')
        self.publisher = self.create_publisher(String, 'topic', 10)
        self.timer = self.create_timer(1.0, self.timer_callback)
        self.get_logger().info('Node initialized')
    
    def timer_callback(self):
        msg = String()
        msg.data = 'Hello ROS 2'
        self.publisher.publish(msg)

def main(args=None):
    rclpy.init(args=args)
    node = MyNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
```

### Launch File Pattern (Python)

```python
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(package='pkg', executable='node', name='node',
             parameters=[{'param': 'value'}], output='screen')
    ])
```

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| ROS Packages/Nodes/Topics | snake_case | `turtlebot4_base`, `/cmd_vel` |
| Launch Files | snake_case.launch.py | `robot_bringup.launch.py` |
| Python Classes | PascalCase | `OdometryPublisher` |
| Python Functions | snake_case | `calculate_velocity` |
| C++ Classes/Functions | PascalCase/camelCase | `MyClass`, `myFunction` |
| Docker Images/Containers | kebab-case | `turtlebot4-dev` |

## Critical Build Workflow

**ALWAYS follow this order**:

1. **Init submodules**: `git submodule update --init --recursive` (6 submodules required)
2. **Docker**: `make build && make start && make enter`
3. **ROS build** (inside container):
   ```bash
   cd /workspace/robot-agentic-autonomy/ros2_ws
   source /opt/ros/humble/setup.bash
   rosdep install -i --from-path src --rosdistro humble --skip-keys=librealsense2 -y
   colcon build --symlink-install
   source install/setup.bash
   ```

**Known Build Fixes**:
- **GPIOD Error**: See AGENTS.md:107-136 for CMakeLists.txt fix
- **RealSense GPG Key Error**: Fixed in Dockerfile:53-58 (requires both GPG keys)

## Code Standards

- **Always init submodules** before build
- **Work inside Docker** at `/workspace/robot-agentic-autonomy`
- **CycloneDDS required**: `export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`
- **Skip librealsense2**: `--skip-keys=librealsense2` (pre-installed)
- **Symlink install**: `colcon build --symlink-install`
- **ROS logging**: `self.get_logger().info()` (Python), `RCLCPP_INFO()` (C++)
- **Declare parameters**: Always use `declare_parameter()` for config
- **Launch files required**: Never hardcode node startup

## Network Configuration

**Wi-Fi (Discovery Server)**:
- Host: `make discovery-server` (port 11811)
- Robot web UI: Enable discovery server → `<HOST_IP>:11811`
- Container: `export ROS_DISCOVERY_SERVER=<HOST_IP>:11811`

**LAN/USB-C (192.168.186.0/24)**:
- Robot: `192.168.186.2`, Host: `192.168.186.3` (via `scripts/set_ip.sh`)
- Container: `export ROS_DISCOVERY_SERVER=192.168.186.2:11811`
- Verify: `make ping-robot-lan`

**Both require**: `export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`

## Security & Safety

**ROS 2 Security**:
- Never expose to public networks (use VPN/firewall)
- Validate sensor data ranges before use in control loops
- Implement safety limits on `/cmd_vel` velocity commands
- Use parameter validation for all user-configurable values

**Hardware Safety**:
- Physical e-stop always accessible
- Monitor `/battery_state` for low voltage
- Test in simulation first (`turtlebot4_simulator`)
- USB-C: Verify physical toggle in USB mode

**Docker Security**:
- `--privileged` only in dev, not production
- Pin versions (RealSense 2.54.2 for L515)
- Regular base image updates

## Testing & Verification

**Basic Connection Test** (inside container):
```bash
ros2 topic list         # Should show robot topics
ros2 topic echo /odom   # Verify odometry data
ros2 topic echo /scan   # Verify LIDAR data
```

**Expected Topics**: `/cmd_vel`, `/odom`, `/scan`, `/battery_state`, `/imu`, `/camera/*`

## 📂 Codebase References

- `Makefile` - Docker orchestration, connection management
- `docker/Dockerfile` - Dev environment (osrf/ros:humble-desktop base)
- `ros2_ws/src/` - ROS packages (6 git submodules)
- `.gitmodules` - Submodule config (turtlebot4, realsense-ros, urg_node2)
- `dependencies.repos` - vcstool manifest (create3_sim, irobot_create_msgs)
- `scripts/set_ip.sh` - LAN/USB-C IP config
- `README.md`, `AGENTS.md` - Setup guides

## Version History

**1.0** (2026-05-16): Initial TurtleBot4 ROS 2 technical domain

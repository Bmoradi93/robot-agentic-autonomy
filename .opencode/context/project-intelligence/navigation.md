<!-- Context: project-intelligence/navigation | Priority: critical | Version: 1.0 | Updated: 2026-05-16 -->

# Project Intelligence Navigation

**Purpose**: Quick reference to all project intelligence files.
**Last Updated**: 2026-05-16

---

## Available Context Files

| File | Description | Priority | Updated |
|------|-------------|----------|---------|
| [technical-domain.md](technical-domain.md) | Tech stack, ROS 2 patterns, build workflow | critical | 2026-05-16 |

---

## Quick Links

### Essential Reading
1. **Start Here**: [technical-domain.md](technical-domain.md) - Complete technical overview
2. **Setup Guide**: `../../README.md` - Quick start and prerequisites
3. **Agent Instructions**: `../../AGENTS.md` - Compact development workflow

### Key Patterns
- **ROS 2 Nodes**: See technical-domain.md → Development Patterns → Python ROS 2 Node Pattern
- **Launch Files**: See technical-domain.md → Development Patterns → Launch File Pattern
- **Build Workflow**: See technical-domain.md → Build & Workflow Standards
- **Network Setup**: See technical-domain.md → Network Configuration

### Common Tasks
- **First-time setup**: Initialize git submodules → Build Docker → Build ROS workspace
- **Connect to robot**: `make discovery-server` (Wi-Fi) or configure LAN/USB-C network
- **Build code**: Inside container → `colcon build --symlink-install`
- **Test connection**: `ros2 topic list` and `ros2 topic echo /odom`

---

## Update Triggers

Update project intelligence when:
- Adding new ROS packages or dependencies
- Changing build workflow or Docker configuration
- Updating hardware components (sensors, actuators)
- Modifying network configuration (discovery server, static IPs)
- Discovering new build issues or workarounds

---

## Version History

- **1.0** (2026-05-16): Initial navigation file for TurtleBot4 project intelligence

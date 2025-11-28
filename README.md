# Robot Agentic Autonomy

This repository provides a Docker-based development environment for agentic autonomy absed on the TurtleBot4. This setup builds a comprehensive ROS 2 Humble environment from the official `osrf/ros:humble-desktop` base image and includes all necessary packages to communicate with the TurtleBot4, including the `CycloneDDS` middleware required for recent firmware versions.

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/) must be installed on your system.
-   Your user must be in the `docker` group to run Docker commands without `sudo`.
-   You have a physical network connection to your TurtleBot4 (either Wi-Fi, a direct LAN cable, or a USB-C data cable).

## Quick Start

1.  **Build the Docker Image:**
    -   Open a terminal in the project directory and run:
        ```bash
        make build
        ```
    -   This will build a local Docker image named `turtlebot4-dev` with the required dependencies.

2.  **Start the Container:**
    -   Once the build is complete, start the container:
        ```bash
        make start
        ```
    -   This will run the container in the background, named `turtlebot4-container`.

3.  **Enter the Container:**
    -   Once the container is running, use the following command to get a shell inside it:
        ```bash
        make enter
        ```
    -   This command will ask you to choose your connection method (Wi-Fi or Direct LAN/USB-C) and will automatically configure the ROS 2 environment for you.

4.  **View Robot Topics:**
    -   Inside the container's shell, you can now run ROS 2 commands to interact with your robot:
        ```bash
        ros2 topic list
        ```

## Connecting to the TurtleBot4

This project supports two connection methods, which are handled by the interactive `make enter` command.

### Connecting via Wi-Fi (Recommended)

This method uses a ROS 2 Discovery Server, which provides the most reliable connection.

1.  **Connect Robot and Laptop to the Same Wi-Fi Network:**
    -   Ensure your laptop is connected to your Wi-Fi network.
    -   [Provision the TurtleBot4 to the same Wi-Fi network](https://iroboteducation.github.io/create3_docs/setup/provision/).

2.  **Start the Discovery Server on Your Laptop:**
    -   In a separate terminal on your laptop (not in the Docker container), run:
        ```bash
        make discovery-server
        ```
    -   This will start the server and print your laptop's local IP address.

3.  **Configure the Robot to Use the Discovery Server:**
    -   Find your robot's IP address on the Wi-Fi network.
    -   Open a web browser and navigate to the robot's IP address.
    -   Go to the **Application -> Configuration** page.
    -   Check the box to **Enable Fast DDS discovery server**.
    -   In the address field, enter your laptop's IP address (from step 2) followed by `:11811`.
    -   Save the settings and restart the robot's application.

4.  **Connect from the Docker Container:**
    -   Run `make enter` and select the **Wi-Fi** option. It will ask for your laptop's IP to complete the connection.

### Connecting via LAN / USB-C

This method creates a direct, private network between your laptop and the robot.

1.  **Physical Connection:**
    -   **For USB-C:** Ensure the physical **USB/BLE toggle switch** on the robot's adapter board is set to the **USB** position. Connect a USB-C cable from the robot to your laptop.
    -   **For LAN:** Connect a standard Ethernet cable from your laptop's LAN port to the robot's Ethernet port.

2.  **Network Configuration:**
    -   The robot's static IP address on this direct link is `192.168.186.2`.
    -   You must configure your laptop's corresponding network interface with a static IP on the same network: `192.168.186.3` with a subnet mask of `255.255.255.0`.
    -   Verify the connection with `make ping-robot-lan`.

3.  **Connect from the Docker Container:**
    -   Run `make enter` and select the **Direct LAN / USB-C** option.

## `Makefile` Commands

-   `make help`: Show the help message.
-   `make build`: Build the custom `turtlebot4-dev` Docker image.
-   `make start`: Run the Docker container in the background.
-   `make enter`: Enter the running container with an interactive shell.
-   `make stop`: Stop and remove the container.
-   `make restart`: Restart the container.
-   `make status`: Show the status of the container and image.
-   `make logs`: View the container's logs.
-   `make discovery-server`: Run the ROS 2 Discovery Server on your laptop.
-   `make ping-robot-lan`: Ping the robot on its static LAN IP.
-   `make clean-all`: Stop and remove all Docker containers and images on your system.
.DEFAULT_GOAL := help

help:
	@echo "Makefile for TurtleBot4 Development"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  help                        Show this help message"

# Docker Management
build:
	docker build -t turtlebot4-dev docker

build-no-cache:
	docker build --no-cache -t turtlebot4-dev docker

start:
	docker run -d --name turtlebot4-container -it --net=host --privileged -v /dev:/dev -v /tmp/.X-unix:/tmp/.X-unix:rw -e DISPLAY=$(DISPLAY) turtlebot4-dev

enter:
	@echo "Select connection method:"
	@echo "  1. Wi-Fi (Discovery Server)"
	@echo "  2. Direct LAN / USB-C"
	@read -p "Enter your choice [1-2]: " choice; \
	case $$choice in \
		1) \
			echo "Entering with Wi-Fi (Discovery Server) configuration..."; \
			read -p "Enter this computer's local Wi-Fi IP address: " HOST_IP; \
			if [ -z "$$HOST_IP" ]; then echo "IP address cannot be empty."; exit 1; fi; \
			docker exec -it turtlebot4-container bash -c "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp && export ROS_DISCOVERY_SERVER=$$HOST_IP:11811 && bash"; \
			;; \
		2) \
			echo "Entering with Direct LAN / USB-C configuration..."; \
			docker exec -it turtlebot4-container bash -c "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp && export ROS_DISCOVERY_SERVER=192.168.186.2:11811 && bash"; \
			;; \
		*) \
			echo "Invalid choice."; \
			exit 1; \
			;; \
	esac

stop:
	docker stop turtlebot4-container && docker rm -f turtlebot4-container

restart:
	docker restart turtlebot4-container

status:
	docker ps -a --filter "name=turtlebot4-container"
	@echo ""
	@echo "Image status:"
	docker images turtlebot4-dev

logs:
	docker logs turtlebot4-container

# Cleanup
clean:
	docker image prune -f

clean-all:
	docker rm -f $(docker ps -a -q)
	docker image prune -a -f

reset: stop clean start

# ROS 2 Discovery Server (for Wi-Fi connections)
discovery-server:
	@echo "Starting Fast DDS Discovery Server..."
	@echo "Your local IP address is: $(shell hostname -I | awk '{print $$1}')"
	fastdds discovery -i 0 -l $(shell hostname -I | awk '{print $$1}') -p 11811

# Robot Discovery
ping-robot:
	ping -c 4 ubuntu.local

ping-robot-lan:
	ping -c 4 192.168.186.2

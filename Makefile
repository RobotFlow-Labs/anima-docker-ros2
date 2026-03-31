SHELL := /bin/bash

.PHONY: help up up-dev up-sim up-usb up-serial up-camera up-audio build build-dev build-sim shell shell-dev shell-sim shell-usb shell-serial shell-camera shell-audio logs stop clean bake doctor open import export status url demo install-cli env password foxglove

help:
	@echo "Targets:"
	@echo "  make up      - build, run, and open the default desktop experience"
	@echo "  make up-dev  - build and run the dev profile"
	@echo "  make up-sim  - build and run the sim profile"
	@echo "  make up-usb  - build and run the desktop with USB passthrough"
	@echo "  make up-serial - build and run the desktop with serial passthrough"
	@echo "  make up-camera - build and run the desktop with camera passthrough"
	@echo "  make up-audio - build and run the desktop with audio passthrough"
	@echo "  make build   - build the default desktop image"
	@echo "  make build-dev - build the dev profile image"
	@echo "  make build-sim - build the sim profile image"
	@echo "  make shell   - open a shell inside the desktop image"
	@echo "  make shell-dev - open a shell using the dev profile"
	@echo "  make shell-sim - open a shell using the sim profile"
	@echo "  make shell-usb - open a shell with USB passthrough"
	@echo "  make shell-serial - open a shell with serial passthrough"
	@echo "  make shell-camera - open a shell with camera passthrough"
	@echo "  make shell-audio - open a shell with audio passthrough"
	@echo "  make logs    - stream compose logs"
	@echo "  make stop    - stop the running stack"
	@echo "  make clean   - stop the stack and remove volumes"
	@echo "  make bake    - build the full matrix in parallel with buildx bake"
	@echo "  make doctor  - verify Docker and Compose are available"
	@echo "  make open    - open the desktop in your browser"
	@echo "  make status  - show the active env, URL, and container health"
	@echo "  make url     - print the current ANIMA URL"
	@echo "  make demo    - seed the workspace with a RobotFlowLabs demo package"
	@echo "  make install-cli - install the local anima CLI into ~/.local/bin"
	@echo "  make env     - print the resolved runtime configuration"
	@echo "  make password - print the current local desktop password"
	@echo "  make foxglove - start the Foxglove bridge on the dev profile"
	@echo "  make import  - import a workspace archive or directory into the container"
	@echo "  make export  - export the workspace volume to an archive"

up:
	./anima up

up-dev:
	./anima up dev

up-sim:
	./anima up sim

up-usb:
	./anima up --hardware usb

up-serial:
	./anima up --hardware serial

up-camera:
	./anima up --hardware camera

up-audio:
	./anima up --hardware audio

build:
	./anima build

build-dev:
	./anima build dev

build-sim:
	./anima build sim

shell:
	./anima shell

shell-dev:
	./anima shell dev

shell-sim:
	./anima shell sim

shell-usb:
	./anima shell --hardware usb

shell-serial:
	./anima shell --hardware serial

shell-camera:
	./anima shell --hardware camera

shell-audio:
	./anima shell --hardware audio

logs:
	./anima logs

stop:
	./anima stop

clean:
	./anima clean

bake:
	./anima bake

doctor:
	./anima doctor

open:
	./anima open

status:
	./anima status

url:
	./anima url

demo:
	./anima demo

install-cli:
	./anima install-cli

env:
	./anima env

password:
	./anima password

foxglove:
	./anima foxglove dev

import:
	./anima import "$${SRC}"

export:
	./anima export "$${DEST}"

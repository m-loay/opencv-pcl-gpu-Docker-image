# Docker container images opencv,pcl & gtest Nvidia Support
This repository developed from nvidia/opengl and nvidia/cuda conatiners, combine these two together to 
create a develope environment in docker


## Requirement
* Docker and Nvidia-docker(docker nvidia runtime) on the host: Check with [NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
* X11 Server install:

      $ apt-get install xauth xorg openbox

## Usage

- Build an image from scratch:

      docker build -t mloay/opencv-pcl-gpu .

## Run
use melodic.bash



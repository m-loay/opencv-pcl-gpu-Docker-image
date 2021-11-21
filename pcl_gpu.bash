#!/bin/bash
xhost +local:root
nvidia-docker run -it \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v /home/mloay/Documents/git:/home/git \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    mloay/opencv-pcl-gpu \
    bash

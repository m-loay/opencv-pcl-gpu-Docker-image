#!/bin/bash
xhost +local:root
docker run -it --rm --runtime=nvidia --gpus all \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v /home/mody/git:/home/git \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    dev-env-gpu \
    bash

# CUDA 11.2 Update 1 (11.2.1) + OpenGL (glvnd 1.2)
FROM nvidia/cudagl:11.2.0-devel-ubuntu20.04
LABEL maintainer "Mohamed Loay"

# ======== Image Configuration  ========
ENV jCore="-j8"
ENV VTK_VERSION="8.2.0"
ENV VTK_FOLDER="8.2"
ENV PCL_VERSION="1.11.0"
ENV CUDNN_VERSION="cudnn-10.0-linux-x64-v7.6.5.32"
ENV OPENCV_VERSION="4.5.1"
ENV PYTHON_VERSION 3.8

# ======== Install sudo & update system ========
RUN apt-get update -y
RUN apt-get install -y sudo
RUN apt-get update && apt-get install -y sudo apt-utils curl
RUN sudo apt-get update && sudo apt-get -y upgrade

# ======== Environment config ========
ENV DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_FRONTEND=noninteractive

# ======== Installing Generic Tools ========

#install general libs
RUN apt-get update \
    && apt-get install -y \
    build-essential \
    cmake \
    make \
    gdb \
    g++ \
    git \
    git-lfs \
    wget \
    unzip \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libxine2-dev \
    libatlas-base-dev \
    libssl-dev \
    libgl1-mesa-dev \
    python$PYTHON_VERSION \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-matplotlib \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCV dependencies
RUN pip3 install numpy

# GTK lib for the graphical user functionalites coming from OpenCV highghui module 
RUN  apt-get update && apt-get install -y \ 
    libgtk-3-dev \
    libtbb-dev \
    libatlas-base-dev \
    gfortran \
    libprotobuf-dev \
    protobuf-compiler \
    libgoogle-glog-dev \
    libgflags-dev \
    libgphoto2-dev \
    libeigen3-dev \
    libhdf5-dev doxygen

# PCL dependencies
RUN apt-get install -y \
    libflann-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    libboost-all-dev \
    libusb-1.0-0-dev \
    libusb-dev \
    libopenni-dev \
    libopenni2-dev \
    libpcap-dev \
    libpng-dev \
    mpi-default-dev \
    openmpi-bin \
    openmpi-common \
    libqhull-dev

#install covar
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.8 get-pip.py
RUN pip install gcovr
RUN pip install git+https://github.com/gcovr/gcovr.git

# ======== Install gtest ========
RUN git clone -q https://github.com/google/googletest.git /googletest \
    && mkdir -p /googletest/build \
    && cd /googletest/build \
    && cmake .. && make ${jCore} && make install \
    && cd / && rm -rf /googletest


# ======== Install VTK ========
WORKDIR /tmp/install
RUN sudo apt-get update -y
RUN sudo apt-get install -y libxt-dev

RUN wget https://www.vtk.org/files/release/${VTK_FOLDER}/VTK-${VTK_VERSION}.tar.gz 
RUN tar -xf VTK-${VTK_VERSION}.tar.gz
RUN cd VTK-${VTK_VERSION}  \
    && mkdir build && cd build \    
    && cmake .. -D VTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES \
    -D CMAKE_BUILD_TYPE=Release \
    -D WITH_CUDA=true  \
    -D CUDA_ARCH_BIN=7.5 \
    -D BUILD_GPU=true  \
    && make ${jCore} && make install
RUN unset VTK_VERSION
RUN unset VTK_FOLDER

# ======== Install PCL ========
WORKDIR /tmp/install

# Download and Install PCL
RUN wget https://github.com/PointCloudLibrary/pcl/archive/pcl-${PCL_VERSION}.tar.gz \
    && tar -xf pcl-${PCL_VERSION}.tar.gz \
    && cd pcl-pcl-${PCL_VERSION} \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DVTK_RENDERING_BACKEND=OpenGL2 \
    -DWITH_CUDA=true  \
    -D CUDA_ARCH_BIN=7.5 \
    -DBUILD_GPU=true  \
    && make ${jCore}\
    && make install

RUN apt-get update && apt-get install -y pcl-tools
RUN unset PCL_VERSION

# ======== Install OpenCv ========
WORKDIR /tmp/install

# Install CUDNN for OpenCV
COPY ${CUDNN_VERSION}.tgz /tmp/install/${CUDNN_VERSION}.tgz
RUN tar -zxvf ${CUDNN_VERSION}.tgz \
    && sudo cp cuda/include/cudnn.h /usr/local/cuda/include/ \
    && sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64/ \
    && sudo chmod a+r /usr/local/cuda/include/cudnn.h \
    && sudo chmod a+r /usr/local/cuda/lib64/libcudnn*
RUN unset CUDNN_VERSION

# Download and Install OpenCV
RUN wget https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip \
    && unzip opencv.zip \
    && wget https://github.com/Itseez/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib.zip \
    && unzip opencv_contrib \
    && cd opencv-${OPENCV_VERSION} \
    && mkdir build && cd build \
    && cmake .. -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
    -D BUILD_EXAMPLES=ON \
    -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -DWITH_EIGEN=ON \
    -D WITH_CUBLAS=ON \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 \
    -D CUDA_ARCH_BIN=7.5 \
    -D WITH_CUBLAS=1 \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python$PYTHON_VERSION \
    -D PYTHON3_EXECUTABLE=/usr/bin/python$PYTHON_VERSION \
    .. && \
    make ${jCore} && \
    make install && \
    ldconfig

RUN unset OPENCV_VERSION
# Set environment variable for OpenCV library path
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# ========  Create a symbolic link for Python ======== #
RUN ln -s /usr/bin/python$PYTHON_VERSION /usr/bin/python

# ======== Clean ========
WORKDIR /tmp/install
RUN ls
RUN rm -r *

# ======== Update system ========
WORKDIR /
RUN sudo apt-get update && sudo apt-get -y upgrade

# Expose Jupyter 
EXPOSE 8888

# Expose Tensorboard
EXPOSE 6006

### Switch to root user to install additional software
USER $USER

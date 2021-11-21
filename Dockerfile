# CUDA 11.2 Update 1 (11.2.1) + OpenGL (glvnd 1.2)
FROM nvidia/cudagl:11.2.0-devel-ubuntu20.04

LABEL maintainer "Mohamed Loay"

# ======== Install sudo & update system ========
RUN apt-get update && apt-get install -y sudo apt-utils curl
RUN sudo apt-get update && sudo apt-get -y upgrade

# ======== Environment config ========
ENV DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_FRONTEND=noninteractive

# ======== Installing Generic Tools ========
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        apt-utils \
        wget \
        unzip \
        git \
        git-lfs \
        gdb \
        g++ \
        python3.8 \
        libpython3-dev \
        make \
        python3-dev \
        python3-numpy \
        python3-matplotlib \
        ninja-build \
        libssl-dev \
        libgl1-mesa-dev \
        cmake \
        gnuplot \
        gcovr \
        googletest

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.8 get-pip.py
RUN pip install gcovr
RUN pip install git+https://github.com/gcovr/gcovr.git

# ======== Installing gtest ========
RUN apk add --no-cache -q -f git cmake make g++
RUN git clone -q https://github.com/google/googletest.git /googletest \
  && mkdir -p /googletest/build \
  && cd /googletest/build \
  && cmake .. && make && make install \
  && cd / && rm -rf /googletest

# ======== GTK lib for the graphical user functionalites coming from OpenCV highghui module  ========
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y \ 
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


# ======== Installing VTK ========
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp/install
RUN sudo apt-get update -y
RUN sudo apt-get install -y libxt-dev

RUN wget https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz 
RUN tar -xf VTK-8.2.0.tar.gz
RUN cd VTK-8.2.0  \
    && mkdir build && cd build \    
    && cmake .. -G Ninja -D VTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES \
                -D CMAKE_BUILD_TYPE=Release \
                -D WITH_CUDA=true  \
                -D CUDA_ARCH_BIN=7.5 \
                -D BUILD_GPU=true  \
    && ninja -j$(nproc) && ninja install

# ======== Installing PCL library ========
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp/install
ENV PCL_VERSION="1.11.0"

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

RUN wget https://github.com/PointCloudLibrary/pcl/archive/pcl-${PCL_VERSION}.tar.gz \
    && tar -xf pcl-${PCL_VERSION}.tar.gz \
    && cd pcl-pcl-${PCL_VERSION} \
    && mkdir build \
    && cd build \
    && cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release \
                -DVTK_RENDERING_BACKEND=OpenGL2 \
                -DWITH_CUDA=true  \
                -D CUDA_ARCH_BIN=7.5 \
                -DBUILD_GPU=true  \
    && ninja -j$(nproc)\
    && ninja install

RUN apt-get update && apt-get install -y pcl-tools
RUN unset PCL_VERSION


# ======== Installing OpenCv ========
# Python libraries for python3
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home
#download open cv and install it
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp/install

COPY cudnn-10.0-linux-x64-v7.6.5.32.tgz /tmp/install/cudnn-10.0-linux-x64-v7.6.5.32.tgz
RUN tar -zxvf cudnn-10.0-linux-x64-v7.6.5.32.tgz \
&& sudo cp cuda/include/cudnn.h /usr/local/cuda/include/ \
&& sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64/ \
&& sudo chmod a+r /usr/local/cuda/include/cudnn.h \
&& sudo chmod a+r /usr/local/cuda/lib64/libcudnn*


ENV OPENCV_VERSION="4.5.0"
RUN wget https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip \
    && unzip opencv.zip \
    && wget https://github.com/Itseez/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib.zip \
    && unzip opencv_contrib \
    && cd opencv-${OPENCV_VERSION} \
    && mkdir build && cd build \
    && cmake .. -G Ninja -D CMAKE_BUILD_TYPE=RELEASE \
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
    -DBUILD_opencv_python3=ON \
	-D WITH_CUDNN=ON \
	-D OPENCV_DNN_CUDA=ON \
	-D ENABLE_FAST_MATH=1 \
	-D CUDA_FAST_MATH=1 \
	-D CUDA_ARCH_BIN=7.5 \
	-D WITH_CUBLAS=1 \
    -DCMAKE_INSTALL_PREFIX=$(python3.8 -c "import sys; print(sys.prefix)") \
    -DPYTHON_EXECUTABLE=$(which python3.8) \
    -DPYTHON_INCLUDE_DIR=$(python3.8 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DPYTHON_PACKAGES_PATH=$(python3.8 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
    -DBUILD_opencv_world=OFF \
     && sudo ninja -j$(nproc) \
     && sudo ninja install \
     && sudo ldconfig

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
FROM ubuntu:16.04
USER root

LABEL maintainer="https://gcamer.li"

# Set environment variables
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNLEVEL=1

# Install build tools
RUN apt-get update
RUN apt-get install -y \
	apt-utils \
	xterm \
	dialog \
	build-essential \
	autoconf \
	dh-autoreconf \
	automake \
	autogen \
	libtool \
	git \
	screen \
	libudev-dev \
	xserver-xorg-core \
	xserver-xorg-video-ati \
	gdebi \
	unzip \
	execstack \
	dh-modaliases \
	lib32gcc1 \
	dkms \
	yasm \
	curl \
	lsb-release \ 
	libcurl4-openssl-dev \ 
	pkg-config \
	libncurses5-dev \
	libevent-pthreads-2.0.5 \
	libjansson-dev \
	ocl-icd-opencl-dev \
	libgl1-mesa-glx \
	libgl1-mesa-dri \
	opencl-headers \
	mesa-utils \
	libglu1-mesa \
	xserver-xorg-video-amdgpu \
	libssl-dev \
	libgmp-dev

# Clean apt lists
RUN rm -rf /var/lib/apt/lists/*

# Add name to Docker image
ENV NAME=sgminer

# Create sgminer dir
WORKDIR /root

# Clone sgminer-gm
RUN git clone --progress --verbose https://projects.owldevelopers.tk/cryptocoin/sgminer-gm.git
WORKDIR /root/sgminer-gm

# Install jansson modules
RUN git checkout test
RUN git submodule init
RUN git submodule update

# Extract AMD SDK
COPY ./AMD-APP-SDK*.tar.bz2 .
RUN tar -xvf AMD-APP-SDK*.tar.bz2 && rm AMD-APP-SDK*.tar.bz2

# Install AMD SDK
RUN chmod +x AMD-APP-SDK-*.sh
RUN ./AMD-APP-SDK-*.sh -- --acceptEULA 'yes' -s

# Remove AMD SDK installation files
RUN rm AMD-APP-SDK-*.sh && rm -rf AMDAPPSDK-*

# Remove AMD SDK samples
RUN rm -rf /opt/AMDAPPSDK-*/samples/{aparapi,bolt,opencv}

# Put includes and lib in the right path
RUN ln -s /opt/AMDAPPSDK-3.0/include/CL /usr/include/CL && ln -s /opt/AMDAPPSDK-3.0/lib/x86_64/sdk/libOpenCL.so.1 /usr/lib/libOpenCL.so

# Extract AMD GPU Pro
COPY ./amdgpu-pro-17.30-*.tar.xz .
RUN tar -xpvf amdgpu-pro-17.30-465504.tar.xz
RUN rm amdgpu-pro-17.30-*.tar.xz

# Install AMD GPU Pro
WORKDIR /root/sgminer-gm/amdgpu-pro-17.30-465504/
RUN ./amdgpu-pro-install -y
WORKDIR /root/sgminer-gm

# Remove AMD GPU Pro files
RUN rm -rf amdgpu-pro-17.30-* 

# Set environment variables
ENV PATH=$PATH:/root/sgminer-gm/
ENV DISPLAY=:0
ENV GPU_USE_SYNC_OBJECTS=1
ENV GPU_MAX_ALLOC_PERCENT=100

# Build sgminer
RUN autoreconf -i
RUN CFLAGS="-02 -Wall -march=native"
RUN ./configure
RUN make

# Execute sgminer
ENTRYPOINT ["sgminer"]
CMD ["--help"]

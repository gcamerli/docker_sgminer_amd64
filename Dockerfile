FROM debian:stretch
USER root

LABEL maintainer="https://gcamer.li"

# Set environment variables
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNLEVEL=1
RUN echo "deb http://deb.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list
RUN echo "deb http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org stretch/updates main contrib non-free" >> /etc/apt/sources.list

# Install build tools
RUN apt update
RUN apt upgrade
RUN apt install -y \
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
	libssl-dev \
	libgmp-dev \
	firmware-linux \
	llvm-3.9 \
	clang-3.9

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
RUN rm AMD-APP-SDK-*.sh

# Remove AMD SDK samples
RUN rm -rf /opt/AMDAPPSDK-*/samples/{aparapi,bolt,opencv}

# Put includes and lib in the right path
RUN ln -s /opt/AMDAPPSDK-3.0/include/CL /usr/include/CL && \ 
	ln -s /opt/AMDAPPSDK-3.0/lib/x86_64/sdk/libOpenCL.so.1 /usr/lib/libOpenCL.so

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

FROM ubuntu:xenial

# REQUIREMENTS
RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y \ 
	libsuitesparse-dev \ 
	libeigen3-dev \ 
	libboost-all-dev \ 
	libopencv-dev \ 
	zlib1g-dev \ 
	libglew-dev \
	libpython2.7-dev \
	git \
	cmake \
	wget \
	unzip

# ZIPCONF
COPY ./thirdparty /dso/thirdparty
WORKDIR /dso/thirdparty
RUN tar -zxvf libzip-1.1.1.tar.gz 
WORKDIR /dso/thirdparty/libzip-1.1.1/
RUN ./configure
RUN make
RUN make install
RUN cp lib/zipconf.h /usr/local/include/zipconf.h

# PANGOLIN
WORKDIR /dso/thirdparty
RUN git clone https://github.com/stevenlovegrove/Pangolin.git
WORKDIR /dso/thirdparty/Pangolin
RUN mkdir -p /dso/thirdparty/Pangolin/build
WORKDIR /dso/thirdparty/Pangolin/build
RUN cmake ..
RUN cmake --build .

# BUILD
COPY ./src /dso/src
COPY ./cmake /dso/cmake
COPY ./CMakeLists.txt /dso/CMakeLists.txt
RUN mkdir -p /dso/build
WORKDIR /dso/build
RUN cmake ..
RUN make -j

# DATASET
RUN wget http://vision.in.tum.de/mono/dataset/sequence_13.zip
RUN unzip sequence_13
RUN	bin/dso_dataset \
		files=sequence_13/images.zip \
		calib=sequence_13/camera.txt \
		gamma=sequence_13/pcalib.txt \
		vignette=sequence_13/vignette.png \
		preset=0 \
		mode=0

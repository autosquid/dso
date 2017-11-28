FROM ubuntu:xenial

# REQUIREMENTS
RUN apt-get update
RUN apt-get install -y libsuitesparse-dev libeigen3-dev libboost-all-dev libopencv-dev zlib1g-dev cmake

# THIRDPARTY
COPY . /dso/
WORKDIR /dso/thirdparty
RUN tar -zxvf libzip-1.1.1.tar.gz 
WORKDIR /dso/thirdparty/libzip-1.1.1/
RUN ./configure
RUN make
RUN make install
RUN cp lib/zipconf.h /usr/local/include/zipconf.h

# BUILD
RUN mkdir -p /dso/build
WORKDIR /dso/build
RUN cmake ..
RUN make -j

# DATASET
RUN wget http://vision.in.tum.de/mono/dataset/sequence_16.zip

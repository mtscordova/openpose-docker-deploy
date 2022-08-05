# https://hub.docker.com/r/cwaffles/openpose
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

#get deps
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
python3-dev python3-pip python3-setuptools git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
libgoogle-glog-dev libboost-all-dev libcaffe-cuda-dev libhdf5-dev libatlas-base-dev

#for python api
RUN pip3 install --upgrade pip
RUN pip3 install numpy opencv-python

#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

#get openpose
WORKDIR /openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

#build it
WORKDIR /openpose/build
#RUN cmake -DBUILD_PYTHON=ON .. && make -j `nproc`
RUN cmake -DBUILD_PYTHON=ON -DCUDA_ARCH=Manual -DCUDA_ARCH_BIN="80 86 87" -DCUDA_ARCH_PTX="86" .. && make -j `nproc`
WORKDIR /openpose

RUN pip3 install Flask Flask_Cors
RUN pip3 install install gunicorn

WORKDIR /openpose/build/python/openpose

RUN make install

RUN cp ./pyopenpose.cpython-36m-x86_64-linux-gnu.so /usr/local/lib/python3.6/dist-packages

RUN cd /usr/local/lib/python3.6/dist-packages && ln -s pyopenpose.cpython-36m-x86_64-linux-gnu.so pyopenpose

RUN export LD_LIBRARY_PATH=/openpose/build/python/openpose

WORKDIR /openpose/models

RUN bash getModels.sh

WORKDIR /openpose/examples/tutorial_api_python

COPY ./openpose_demo.py .
COPY ./app.py .
COPY ./wsgi.py .

EXPOSE 5000


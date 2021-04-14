FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install -y bash git wget flex bison gperf\
    python-setuptools cmake ninja-build ccache\
    libffi-dev libssl-dev dfu-util curl unzip xxd\
    python3 python3-pip python3-setuptools zip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

ARG tensorflow_version=master
ARG esp_idf_version=master

RUN mkdir /src

WORKDIR /src

RUN mkdir esp && cd esp && git clone --recursive https://github.com/espressif/esp-idf.git
RUN cd esp/esp-idf && git checkout ${esp_idf_version}
RUN cd esp/esp-idf && git submodule update --init --recursive

RUN git clone --depth 1 https://github.com/tensorflow/tensorflow.git -b ${tensorflow_version}

RUN cd esp/esp-idf && ./install.sh

RUN IDF_PATH="/src/esp/esp-idf" . esp/esp-idf/export.sh && \
    pip3 install six && \
    cd tensorflow && \
    IDF_PATH="/src/esp/esp-idf" make -f tensorflow/lite/micro/tools/make/Makefile TARGET=esp generate_hello_world_esp_project

CMD ["cp", "-R", "/src/tensorflow/tensorflow/lite/micro/tools/make/gen/esp_xtensa-esp32_default/prj/hello_world/esp-idf/components/tfmicro", "/dst"]

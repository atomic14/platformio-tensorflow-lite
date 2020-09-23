FROM ubuntu:18.04

RUN apt-get update -y
RUN apt-get install -y git wget flex bison gperf python python-pip\
    python-setuptools cmake ninja-build ccache\
    libffi-dev libssl-dev dfu-util curl unzip xxd\
    python3 python3-pip python3-setuptools
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

ARG tensorflow_version=r2.3
ARG esp_idf_version=release/v4.2

RUN mkdir /src

WORKDIR /src

RUN git clone --depth 1 https://github.com/tensorflow/tensorflow.git -b ${tensorflow_version}

RUN mkdir esp && cd esp && git clone --recursive https://github.com/espressif/esp-idf.git -b ${esp_idf_version}

RUN cd esp/esp-idf && ./install.sh

RUN . esp/esp-idf/export.sh && \
    cd tensorflow && \
    make -f tensorflow/lite/micro/tools/make/Makefile TARGET=esp generate_hello_world_esp_project

CMD ["cp", "-R", "/src/tensorflow/tensorflow/lite/micro/tools/make/gen/esp_xtensa-esp32/prj/hello_world/esp-idf/components/tfmicro", "/dst"]
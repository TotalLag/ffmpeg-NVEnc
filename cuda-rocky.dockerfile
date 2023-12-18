ARG VER=8

FROM nvidia/cuda:12.3.1-devel-rockylinux${VER} AS build

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

RUN yum group install -y "Development Tools" \
    && yum install -y curl epel-release libva-devel python3 \
    && yum install -y meson ninja-build libass-devel --enablerepo=powertools \
    && rm -rf /var/cache/yum/* /var/cache/dnf/* \
    && yum clean all \
    && alternatives --set python /usr/bin/python3

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg
COPY ./ldd.sh /app/ldd.sh
COPY ./copyfiles.sh /app/copyfiles.sh

RUN SKIPINSTALL=yes /app/build-ffmpeg --build --enable-gpl-and-non-free


FROM rockylinux:${VER}

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

# install va-driver
RUN yum install -y libva xz-utils \
    && rm -rf /var/cache/yum/* \
    && yum clean all

# Copy libnpp
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppc.so.12 /lib64/libnppc.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppig.so.12 /lib64/libnppig.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppicc.so.12 /lib64/libnppicc.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppidei.so.12 /lib64/libnppidei.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppif.so.12 /lib64/libnppif.so.12

# Copy ffmpeg, ffprobe, and ffplay
COPY --from=build /app/workspace/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=build /app/workspace/bin/ffmpeg /app/workspace/bin/ffmpeg

COPY --from=build /app/workspace/bin/ffprobe /usr/bin/ffprobe
COPY --from=build /app/workspace/bin/ffprobe /app/workspace/bin/ffprobe

COPY --from=build /app/workspace/bin/ffplay /usr/bin/ffplay
COPY --from=build /app/workspace/bin/ffplay /app/workspace/bin/ffplay

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg
COPY ./ldd.sh /app/ldd.sh
COPY ./copyfiles.sh /app/copyfiles.sh

# Check shared library
RUN ldd /usr/bin/ffmpeg
RUN ldd /usr/bin/ffprobe
RUN ldd /usr/bin/ffplay

RUN /usr/bin/ffmpeg --help

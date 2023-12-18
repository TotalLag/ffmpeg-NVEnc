#!/bin/bash 

set -e

echo " Archive File and Copying Dynamics Libs"


#copying artificats

## ffmpeg archive 
mkdir -p /app/ffmpeg/bin
mkdir -p /app/ffmpeg/lib
cp /app/workspace/bin/ffmpeg /app/ffmpeg/bin
cp /app/workspace/bin/ffprobe /app/ffmpeg/bin
cp /app/workspace/bin/ffplay /app/ffmpeg/bin
bash /app/ldd.sh /app/workspace/bin/ffmpeg /app/ffmpeg/lib/
OUTPUT_FNAME="ffmpeg-${FFMPEG_VERSION}-rockylinux${VER}.tar.xz"
XZ_OPT="-9e -T0" tar cJf "/app/artifacts/${OUTPUT_FNAME}" -C /app/ffmpeg .
##nvencc archive 
mkdir -p /app/nvencc/bin
mkdir -p /app/nvencc/lib
cp /app/workspace/bin/nvencc /app/nvencc/bin
bash /app/ldd.sh /app/workspace/bin/nvencc /app/nvencc/lib
OUTPUT_FNAME="nvencc-${NVENC_VERSION}-rockylinux${VER}.tar.xz"
XZ_OPT="-9e -T0" tar cJf "/app/artifacts/${OUTPUT_FNAME}" -C /app/nvencc .

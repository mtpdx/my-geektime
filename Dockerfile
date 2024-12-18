FROM golang:1.23 AS golang

ENV GOPROXY="https://goproxy.cn,direct"

WORKDIR /app
COPY . /app

RUN make all

FROM   ubuntu:24.04 AS builder

WORKDIR  /tmp/workdir

COPY  docker/generate-source-of-truth-ffmpeg-versions.py /tmp/workdir
COPY  docker/download_tarballs.sh /tmp/workdir
COPY  docker/build_source.sh /tmp/workdir
COPY  docker/install_ffmpeg.sh /tmp/workdir


ENV FFMPEG_VERSION=7.1
ARG OPENCORE_PKGS="libopencore-amrnb-dev libopencore-amrnb0 libopencore-amrwb-dev libopencore-amrwb0"
ARG X264_PKGS="libx264-164 libx264-dev"
ARG X265_PKGS="libnuma1 libx265-199 libx265-dev"
# libnuma-dev
ARG OGG_PKGS="libogg-dev libogg0"
ARG OPUS_PKGS="libopus-dev libopus0"
ARG VORBIS_PKGS="libvorbis-dev libvorbis0a libvorbisenc2 libvorbisfile3"
ARG VPX_PKGS="libvpx-dev libvpx9"
ARG WEBP_PKGS="libsharpyuv-dev libsharpyuv0 libwebp-dev libwebp7 libwebpdecoder3 libwebpdemux2 libwebpmux3"
ARG MP3LAME_PKGS="libmp3lame-dev libmp3lame0"
ARG XVIDCORE_PKGS="libxvidcore-dev libxvidcore4"
ARG FDKAAC_PKGS="libfdk-aac-dev libfdk-aac2"
ARG OPENJP_PKGS="libopenjp2-7 libopenjp2-7-dev"
ARG FREETYPE_PKGS="libfreetype6-dev"
ARG FONTCONFIG_PKGS="fontconfig libfontconfig-dev libfontconfig1 fontconfig-config fonts-dejavu-core fonts-dejavu-mono"
ARG VIDSTAB_PKGS="libvidstab-dev libvidstab1.1"
ARG FRIBIDI_PKGS="libfribidi-dev libfribidi0"
# libass-dev wanted to install a boat-load of packages
ARG LIBASS_PKGS="libass-dev libass9"
ARG AOM_PKGS="libaom-dev libaom3"
ARG SVTAV1_PKGS="libsvtav1-dev libsvtav1enc-dev libsvtav1enc1d1 libsvtav1dec-dev libsvtav1dec0"
ARG DAV1D_PKGS="libdav1d-dev libdav1d7"
# LIBDRM_PKGS picks ups some of the XORG_MACROS_PKGS as well
ARG XORG_MACROS_PKGS="libxcb-shm0-dev libxcb-shm0 libxcb-xfixes0 libxcb-xfixes0-dev"
ARG XPROTO_PKGS="x11proto-core-dev x11proto-dev"
ARG XAU_PKGS="libxau-dev libxau6"
ARG PTHREADS_STUBS_PKGS="libpthread-stubs0-dev"
ARG XML2_PKGS="libxml2-dev libxml2"
ARG BLURAY_PKGS="libbluray-dev libbluray2"
ARG ZMQ_PKGS="libzmq3-dev libzmq5"
# libpng-tools
ARG PNG_PKGS="libpng-dev libpng16-16t64"
ARG ARIBB24_PKGS="libaribb24-dev"
ARG ZIMG_PKGS="libzimg-dev libzimg2"
ARG THEORA_PKGS="libtheora-dev libtheora0"
ARG SRT_PKGS="libssl-dev libsrt-openssl-dev libsrt1.5-openssl"
ARG LIBDRM_PKGS="libbsd0 libdrm-dev libdrm2 libxcb1-dev libxcb1"

ENV MAKEFLAGS="-j2"
ENV PKG_CONFIG_PATH="/opt/ffmpeg/share/pkgconfig:/opt/ffmpeg/lib/pkgconfig:/opt/ffmpeg/lib64/pkgconfig:/opt/ffmpeg/lib/x86_64-linux-gnu/pkgconfig:/opt/ffmpeg/lib/aarch64-linux-gnu/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig"

ENV PREFIX="/opt/ffmpeg"
ENV LD_LIBRARY_PATH="/opt/ffmpeg/lib:/opt/ffmpeg/lib64:/opt/ffmpeg/lib/aarch64-linux-gnu"


ARG DEBIAN_FRONTEND=noninteractive

RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends curl jq python3 python3-requests less tree file vim && \
        chmod +x /tmp/workdir/generate-source-of-truth-ffmpeg-versions.py && \
        chmod +x /tmp/workdir/download_tarballs.sh && \
        chmod +x /tmp/workdir/build_source.sh && \
        chmod +x /tmp/workdir/install_ffmpeg.sh

RUN      buildDeps="autoconf \
                    automake \
                    cmake \
                    build-essential \
                    texinfo \
                    curl \
                    wget \
                    tar \
                    bzip2 \
                    libexpat1-dev \
                    gcc \
                    git \
                    git-core \
                    gperf \
                    libtool \
                    make \
                    meson \
                    ninja-build \
                    nasm \
                    perl \
                    pkg-config \
                    python3 \
                    yasm \
                    zlib1g-dev \
                    libfreetype6-dev \
                    libgnutls28-dev \
                    libsdl2-dev \
                    libva-dev \
                    libvdpau-dev \
                    libnuma-dev \
                    libdav1d-dev \
                    openssl \
                    libssl-dev \
                    expat \
                    libgomp1" && \
        apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ${buildDeps}

RUN \
        echo "Installing dependencies..." && \
        apt-get install -yq --no-install-recommends ${OPENCORE_PKGS} ${X264_PKGS} ${X265_PKGS} ${OGG_PKGS} ${OPUS_PKGS} ${VORBIS_PKGS} ${VPX_PKGS} ${WEBP_PKGS} ${MP3LAME_PKGS} ${XVIDCORE_PKGS} ${FDKAAC_PKGS} ${OPENJP_PKGS} ${FREETYPE_PKGS} ${VIDSTAB_PKGS} ${FRIBIDI_PKGS} ${FONTCONFIG_PKGS} ${LIBASS_PKGS} ${AOM_PKGS} ${SVTAV1_PKGS} ${DAV1D_PKGS} ${XORG_MACROS_PKGS} ${XPROTO_PKGS} ${XAU_PKGS} ${PTHREADS_STUBS_PKGS} ${XML2_PKGS} ${BLURAY_PKGS} ${ZMQ_PKGS} ${PNG_PKGS} ${ARIBB24_PKGS} ${ZIMG_PKGS} ${THEORA_PKGS} ${SRT_PKGS} ${LIBDRM_PKGS}

        # apt install libdrm-dev

## libvmaf https://github.com/Netflix/vmaf
## https://github.com/Netflix/vmaf/issues/788#issuecomment-756098059
RUN \
        echo "Adding g++ for VMAF build" && \
        apt-get install -yq g++

# Note: pass '--library-list lib1,lib2,lib3 for more control.
#       Here we have 3 libs that we have to build from source
RUN /tmp/workdir/generate-source-of-truth-ffmpeg-versions.py --library-list kvazaar,libvmaf
RUN /tmp/workdir/download_tarballs.sh
RUN /tmp/workdir/build_source.sh

RUN /tmp/workdir/generate-source-of-truth-ffmpeg-versions.py --library-list ffmpeg-7.1
RUN /tmp/workdir/download_tarballs.sh
RUN /tmp/workdir/build_source.sh

## when  debugging you can pass in || true to the end of the command
## to keep the build going even if one of the steps fails
RUN /tmp/workdir/install_ffmpeg.sh


# Stage 2: Final Image ( shrink the size back down )
FROM ubuntu:24.04 AS runtime
# Copy fonts and fontconfig from builder
COPY --from=builder /usr/share/fonts /usr/share/fonts
COPY --from=builder /usr/share/fontconfig /usr/share/fontconfig
COPY --from=builder /usr/bin/fc-* /usr/bin/

# Copy rest of the content
COPY --from=builder /usr/local /usr/local/
COPY --from=golang /app/mygeektime /usr/local/

EXPOSE 8090

ENTRYPOINT ["mygeektime"]

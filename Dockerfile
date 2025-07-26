FROM ubuntu:22.04 


RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    quilt \
    rsync \
    python3 \
    python3-distutils \
    libncurses5-dev \
    unzip \
    gawk \
    wget \
    file \
    time \
    && rm -rf /var/lib/apt/lists/*
# Create working directories
RUN mkdir -p /sdks

# Download and extract both SDKs
RUN wget -q -O /sdks/mt7621_sdk.tar.xz \
    https://downloads.openwrt.org/releases/22.03.0/targets/ramips/mt7621/openwrt-sdk-22.03.0-ramips-mt7621_gcc-11.2.0_musl.Linux-x86_64.tar.xz && \
    tar -xf /sdks/mt7621_sdk.tar.xz -C /sdks && \
    mv /sdks/openwrt-sdk-22.03.0-ramips-mt7621_gcc-11.2.0_musl.Linux-x86_64 /sdks/mt7621 && \
    rm /sdks/mt7621_sdk.tar.xz

RUN wget -q -O /sdks/x86_sdk.tar.xz \
    https://downloads.openwrt.org/releases/22.03.0/targets/x86/generic/openwrt-sdk-22.03.0-x86-generic_gcc-11.2.0_musl.Linux-x86_64.tar.xz && \
    tar -xf /sdks/x86_sdk.tar.xz -C /sdks && \
    mv /sdks/openwrt-sdk-22.03.0-x86-generic_gcc-11.2.0_musl.Linux-x86_64 /sdks/x86 && \
    rm /sdks/x86_sdk.tar.xz

# Create convenience symlinks
RUN ln -s /sdks/mt7621 /mt7621 && \
    ln -s /sdks/x86 /x86


# Create non-root user
RUN useradd -m developer && \
    chown -R developer:developer /sdks

USER developer
WORKDIR /home/developer

# Environment variables for easy access
ENV MT7621_SDK=/mt7621
ENV X86_SDK=/x86

CMD ["/bin/bash"]
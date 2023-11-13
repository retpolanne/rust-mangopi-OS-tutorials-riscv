## SPDX-License-Identifier: MIT OR Apache-2.0
##
## Copyright (c) 2017-2023 Andre Richter <andre.o.richter@gmail.com>
## Copyright (c) 2019-2023 Nao Taco <naotaco@gmail.com>
FROM debian:experimental

ARG VCS_REF
ARG GCC_RISCV64=https://riscvtoolchain.nyc3.digitaloceanspaces.com/riscv64-toolchain-linux-gnu.tar.gz
ARG PYTHON311=https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz

LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials"

LABEL maintainer="The resources team <resources@teams.rust-embedded.org>, Andre Richter <andre.o.richter@gmail.com>"

# Ruby gems
COPY Gemfile .

RUN set -ex;                                      \
    tempPkgs='                                    \
        automake                                  \
        bison                                     \
        build-essential                           \
        flex                                      \
        git                                       \
        libtool                                   \
        ninja-build                               \
        pkg-config                                \
        wget                                      \
    ';                                            \
    apt-get update;                               \
    apt-get install -q -y --no-install-recommends \
        $tempPkgs                                 \
        # persistent packages
        ca-certificates                           \
        gdb-multiarch                             \
        libpixman-1-dev                           \
        libglib2.0-dev                            \
        libusb-1.0.0-dev                          \
        locales                                   \
        openssl                                   \
        python3                                   \
        ruby                                      \
        ruby-dev                                  \
        guile-3.0-dev                             \
    ;                                             \
    wget -q ${GCC_RISCV64};                                                                  \
    tar -xzf riscv*;                                                                        \
    wget -q ${PYTHON311};                                                                  \
    tar -xzf Python*;                                                                        \
    cp                                                                                       \
        riscv/bin/riscv64-unknown-linux-gnu-objdump                                          \
        riscv/bin/riscv64-unknown-linux-gnu-readelf                                          \
        riscv/bin/riscv64-unknown-linux-gnu-nm                                               \
        riscv/bin/riscv64-unknown-linux-gnu-gdb                                              \
        /usr/local/bin/;                                                                     \
    rm -rf riscv;                                                                            \
    cd Python-3.11.0;                                                                            \
    ./configure --enable-optimizations -with-lto --enable-shared;                                 \
    make sharedinstall;                                                                            \
    mv libpython3.11.so.1.0 /usr/lib;                                                               \
    cd ..;                                                                            \
    # Ruby dependencies
    gem install bundler;                             \
    bundle config set --local without 'development'; \
    bundle install --retry 3;                        \
    # QEMU
    git clone https://gitlab.com/qemu-project/qemu.git;        \
    cd qemu;                                                   \
    git checkout tags/v6.1.0;                                  \
    ./configure --target-list=riscv64-softmmu  \
        --enable-modules                                       \
        --enable-tcg-interpreter --enable-debug-tcg            \
        --disable-werror		                       \
        --python=/usr/bin/python3;                             \
    make -j12;                                                 \
    make install;                                              \
    cd ..;                                                     \
    rm -rf qemu;                                               \
    # Openocd
    git clone --depth 1 https://git.code.sf.net/p/openocd/code openocd; \
    cd openocd;                                                         \
    ./bootstrap;                                                        \
    ./configure --enable-ftdi;                                          \
    make -j10;                                                          \
    make install;                                                       \
    # GDB
    wget -P ~ git.io/.gdbinit; \
    # Cleanup
    apt-get purge -y --auto-remove $tempPkgs; \
    apt-get autoremove -q -y;                 \
    apt-get clean -q -y;                      \
    rm -rf /var/lib/apt/lists/*

# Locales
RUN locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8   \
    LANGUAGE=en_US:en  \
    LC_ALL=en_US.UTF-8 \
    RUBYOPT=-W0

# Openocd
COPY rpi3.cfg /openocd/
COPY rpi4.cfg /openocd/

# GDB
COPY auto /root/.gdbinit.d/auto

# Rust
RUN apt update && apt install curl -y && curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

ENV RUST_GDB="/usr/local/bin/riscv64-unknown-linux-gnu-gdb"

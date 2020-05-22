#!/bin/bash

REALPATH=$(realpath "${0}")
DIR=$(dirname "${REALPATH}")
test -d output || mkdir output
mkdir /toolchains

sed '/^#/d' < "${DIR}/archs" | while read -r arch; do
    echo "TARGET = $arch" > config.mak
    echo "OUTPUT = /usr" >> config.mak
    cat << EOF >/toolchains/${arch}.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(TOOLCHAIN_PREFIX /usr/bin/${arch})

set(CMAKE_C_COMPILER \${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER \${TOOLCHAIN_PREFIX}-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF
    make -j4 install
done

function make_link(){
    test -f /toolchains/${1}.cmake && ln -s ${1}.cmake /toolchains/${2}.cmake
}

make_link i386-linux-musl i386
make_link x86_64-linux-musl amd64
make_link mips-linux-musl mips
make_link mipsel-linux-musl mipsel
make_link arm-linux-musleabi arm
make_link aarch64-linux-musl arm64

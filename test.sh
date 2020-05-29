#!/bin/bash

set -e

cat << EOF >main.c
#include <stdio.h>

int main(int argc, char ** argv) {
    printf("Hello, World!\n");
}
EOF

cat << EOF >CMakeLists.txt
cmake_minimum_required(VERSION 3.5)
project(Test)

set(CMAKE_C_FLAGS "-ggdb")
set(CMAKE_EXE_LINKER_FLAGS -static)
add_executable(musl-test main.c)
EOF

docker run --rm robertlarsen/musl-cross cat /archs | sed '/^#/d' | while read -r arch; do
    BUILD="build-${arch}"
    test -d "${BUILD}" && rm -rf "${BUILD}"
    mkdir "${BUILD}"
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v "$(pwd)/${BUILD}":/build \
        -v "$(pwd)":/project \
        robertlarsen/musl-cross \
        cmake -G Ninja "-DCMAKE_TOOLCHAIN_FILE=/toolchains/${arch}.cmake" /project
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v "$(pwd)/${BUILD}":/build \
        -v "$(pwd)":/project \
        robertlarsen/musl-cross \
        ninja
    cp "${BUILD}/musl-test" "${arch}-test"
    rm -rf "${BUILD}"
done

rm -f main.c CMakeLists.txt

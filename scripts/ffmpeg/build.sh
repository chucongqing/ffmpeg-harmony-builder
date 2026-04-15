#!/bin/bash
#file:build_ohos.sh
# ohos编译安装ffmpeg

# --- sdk路径配置 (请根据实际环境修改) ---
OHOS_SDK="/root/ohos-sdk/linux"

COMPILER_TOOLCHAIN=${OHOS_SDK}/native/llvm/bin/

BUILD_OS=$(uname)

SYSROOT=${OHOS_SDK}/native/sysroot
PKG_CONFIG_SYSROOT_DIR=${SYSROOT}/usr/lib/aarch64-linux-ohos
PKG_CONFIG_PATH=${PKG_CONFIG_SYSROOT_DIR}
PKG_CONFIG_EXECUTABLE=${PKG_CONFIG_SYSROOT_DIR}

TARGET="aarch64-linux-ohos"

LIB_PATH="$SYSROOT/usr/lib/$TARGET"

HNP_PUBLIC_PATH=/data/service/hnp/
FFMPEG_INSTALL_HNP_PATH=${HNP_PUBLIC_PATH}/ffmpeg.org/ffmpeg_8.0.1

WORK_ROOT=${PWD}
ARCHIVE_PATH=${WORK_ROOT}/output

HNP_TOOL=${OHOS_SDK}/toolchains/hnpcli

make clean

mkdir -p ${HNP_PUBLIC_PATH}
mkdir -p ${FFMPEG_INSTALL_HNP_PATH}
mkdir -p ${ARCHIVE_PATH}

chmod 777  -R  ${HNP_PUBLIC_PATH}

./configure \
  --prefix=${FFMPEG_INSTALL_HNP_PATH} \
  --enable-cross-compile \
  --target-os=linux \
  --arch=aarch64 \
  --cpu=armv8-a \
  \
  --host-cc=gcc \
  --cc="$COMPILER_TOOLCHAIN/clang" \
  --cxx="$COMPILER_TOOLCHAIN/clang++" \
  --as="$COMPILER_TOOLCHAIN/clang" \
  --nm="$COMPILER_TOOLCHAIN/llvm-nm" \
  --ar="$COMPILER_TOOLCHAIN/llvm-ar" \
  --ranlib="$COMPILER_TOOLCHAIN/llvm-ranlib" \
  --strip="$COMPILER_TOOLCHAIN/llvm-strip" \
  \
  --sysroot="$SYSROOT" \
  --extra-cflags="--target=$TARGET -fPIC -D__MUSL__=1 -D__OHOS__  -fstack-protector-strong" \
  --extra-ldflags="--target=$TARGET --sysroot=$SYSROOT -fuse-ld=lld -L$LIB_PATH" \
  \
  --enable-shared \
  --disable-static \
  --disable-asm \
  --disable-doc \
  --enable-ffmpeg \
  --disable-ffplay \
  --disable-ffprobe \
  --enable-pic \
  --enable-gpl \
  --enable-nonfree \
  --disable-logging\
  --disable-vulkan \
  --disable-libdrm 

make VERBOSE=1 -j$(nproc) 
make install

# 生成鸿蒙HNP软件包
cp hnp.json ${FFMPEG_INSTALL_HNP_PATH}/
pushd ${FFMPEG_INSTALL_HNP_PATH}/../
    ${HNP_TOOL} pack -i ${FFMPEG_INSTALL_HNP_PATH} -o ${ARCHIVE_PATH}/
    tar -zvcf ${ARCHIVE_PATH}/ohos_ffmpeg_8.0.1.tar.gz ffmpeg_8.0.1/
popd
#!/usr/bin/env bash

export ANDROID_ABI=$1

# HarmonyOS doesn't use API level in compiler wrappers like Android does.
export ANDROID_PLATFORM=1

export TOOLCHAIN_PATH=${OHOS_NDK_HOME}/native/llvm
export SYSROOT_PATH=${TOOLCHAIN_PATH}/sysroot

COMPILER_PREFIX=
CPU_FAMILY=

case $ANDROID_ABI in
  armeabi-v7a)
    export TARGET_TRIPLE_MACHINE_ARCH=arm
    COMPILER_PREFIX=armv7-unknown-linux-ohos
    export TARGET=arm-linux-ohos
    ;;
  arm64-v8a)
    export TARGET_TRIPLE_MACHINE_ARCH=aarch64
    COMPILER_PREFIX=aarch64-unknown-linux-ohos
    export TARGET=aarch64-linux-ohos
    ;;
  x86_64)
    export TARGET_TRIPLE_MACHINE_ARCH=x86_64
    COMPILER_PREFIX=x86_64-unknown-linux-ohos
    export TARGET=x86_64-linux-ohos
    CPU_FAMILY=x86_64
    ;;
esac

[ -z "${CPU_FAMILY}" ] && CPU_FAMILY=${TARGET_TRIPLE_MACHINE_ARCH}
export CPU_FAMILY=$CPU_FAMILY

# Common prefix for ld, as, etc.
export CROSS_PREFIX_WITH_PATH=${TOOLCHAIN_PATH}/bin/llvm-

# Exporting Binutils paths, if passing just CROSS_PREFIX_WITH_PATH is not enough
# The FAM_ prefix is used to eliminate passing those values implicitly to build systems
export FAM_ADDR2LINE=${CROSS_PREFIX_WITH_PATH}addr2line
export        FAM_AR=${CROSS_PREFIX_WITH_PATH}ar
export        FAM_AS=${CROSS_PREFIX_WITH_PATH}as
export        FAM_NM=${CROSS_PREFIX_WITH_PATH}nm
export   FAM_OBJCOPY=${CROSS_PREFIX_WITH_PATH}objcopy
export   FAM_OBJDUMP=${CROSS_PREFIX_WITH_PATH}objdump
export    FAM_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
export   FAM_READELF=${CROSS_PREFIX_WITH_PATH}readelf
export      FAM_SIZE=${CROSS_PREFIX_WITH_PATH}size
export   FAM_STRINGS=${CROSS_PREFIX_WITH_PATH}strings
export     FAM_STRIP=${CROSS_PREFIX_WITH_PATH}strip

export FAM_CC=${TOOLCHAIN_PATH}/bin/${COMPILER_PREFIX}-clang
export FAM_CXX=${TOOLCHAIN_PATH}/bin/${COMPILER_PREFIX}-clang++
export FAM_LD=${FAM_CC}

# Special variable for the yasm assembler
export FAM_YASM=${TOOLCHAIN_PATH}/bin/yasm

# A variable to which certain dependencies can add -l arguments during build.sh
export FFMPEG_EXTRA_LD_FLAGS=

# A variable to which certain dependencies can add addtional arguments during ffmpeg build.sh
export EXTRA_BUILD_CONFIGURATION_FLAGS=

export INSTALL_DIR=${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}

# Forcing FFmpeg and its dependencies to look for dependencies
# in a specific directory when pkg-config is used
export PKG_CONFIG_LIBDIR=${INSTALL_DIR}/lib/pkgconfig

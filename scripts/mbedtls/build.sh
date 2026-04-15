#!/usr/bin/env bash

CMAKE_BUILD_DIR="mbedtls_build_${ANDROID_ABI}"
# mbedtls authors park their source in a directory named  mbedtls-${MBEDTLS_VERSION}
# instead of root directory
cd "mbedtls-${MBEDTLS_VERSION}"
rm -rf "${CMAKE_BUILD_DIR}"
mkdir "${CMAKE_BUILD_DIR}"
cd "${CMAKE_BUILD_DIR}"

"${CMAKE_EXECUTABLE}" .. \
 -DCMAKE_TOOLCHAIN_FILE="${OHOS_NDK_HOME}/native/build/cmake/ohos.toolchain.cmake" \
 -DOHOS_ARCH="${ANDROID_ABI}" \
 -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
 -DENABLE_TESTING=0

"${MAKE_EXECUTABLE}" -j"${HOST_NPROC}"
"${MAKE_EXECUTABLE}" install

export EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS  --enable-protocol=https --enable-version3"

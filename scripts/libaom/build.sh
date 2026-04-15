#!/usr/bin/env bash

# libaom doesn't support building while being in its root directory
CMAKE_BUILD_DIR="aom_build_${ANDROID_ABI}"
rm -rf "${CMAKE_BUILD_DIR}"
mkdir "${CMAKE_BUILD_DIR}"
cd "${CMAKE_BUILD_DIR}"

"${CMAKE_EXECUTABLE}" .. \
 -DCMAKE_TOOLCHAIN_FILE="${OHOS_NDK_HOME}/native/build/cmake/ohos.toolchain.cmake" \
 -DOHOS_ARCH="${ANDROID_ABI}" \
 -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
 -DCONFIG_PIC=1 \
 -DCONFIG_RUNTIME_CPU_DETECT=0 \
 -DENABLE_TESTS=0 \
 -DENABLE_DOCS=0 \
 -DENABLE_TESTDATA=0 \
 -DENABLE_EXAMPLES=0 \
 -DENABLE_TOOLS=0

"${MAKE_EXECUTABLE}" -j"${HOST_NPROC}"
"${MAKE_EXECUTABLE}" install

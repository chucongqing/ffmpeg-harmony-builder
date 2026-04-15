# FFmpeg Build for HarmonyOS

A shell-script-based build system for cross-compiling **FFmpeg** for **HarmonyOS (OpenHarmony) mobile**.

This project was originally bootstrapped from [`ffmpeg-android-maker`](https://github.com/Javernaut/ffmpeg-android-maker) and has been adapted to use the HarmonyOS NDK toolchain.

## Prerequisites

- Linux or macOS build host
- HarmonyOS NDK (native LLVM toolchain + sysroot)
- Standard build tools: `bash`, `make`, `cmake`, `curl`, `git`

## Environment Setup

Set the following environment variables before running the build:

```bash
export OHOS_SDK_HOME=/path/to/ohos-sdk
export OHOS_NDK_HOME=/path/to/ohos-ndk
```

> **Note**: `OHOS_NDK_HOME` is the path that contains the `native/llvm` and `native/sysroot` directories. `OHOS_SDK_HOME` is only checked for presence and is not actively used when building FFmpeg without external libraries.

### Recommended: use the CMake bundled with the NDK

It is recommended to use the CMake provided by the HarmonyOS NDK to avoid toolchain compatibility issues. You can temporarily prepend it to `PATH` before building:

```bash
export PATH="${OHOS_NDK_HOME}/native/build-tools/cmake/bin:${PATH}"
```

## Usage

### Build FFmpeg for a single ABI

```bash
./ffmpeg-harmony-builder.sh --target-abis=arm64-v8a
```

### Build FFmpeg for multiple ABIs

```bash
./ffmpeg-harmony-builder.sh --target-abis=arm64-v8a,armeabi-v7a
```

### Supported ABIs

| ABI | Target Triple |
|-----|---------------|
| `arm64-v8a` | `aarch64-linux-ohos` |
| `armeabi-v7a` | `arm-linux-ohos` |
| `x86_64` | `x86_64-linux-ohos` |

If `--target-abis` is omitted, the default is: `arm64-v8a armeabi-v7a x86_64`.

### Specify FFmpeg version

```bash
# Use a specific release tarball (default: 8.1)
./ffmpeg-harmony-builder.sh --source-tar=7.0 --target-abis=arm64-v8a

# Use a Git tag
./ffmpeg-harmony-builder.sh --source-git-tag=n7.0 --target-abis=arm64-v8a
```

## Output

After a successful build, the shared libraries (`.so`) and headers are placed under:

```
./output/
├── include/<abi>/
└── lib/<abi>/
```

Intermediate build artifacts are stored in:

```
./build/ffmpeg/<abi>/
```

## Tested Status

- **FFmpeg** (without external libraries) — ✅ **Successfully compiled and tested** on HarmonyOS NDK.
- **External libraries** — ⚠️ The build scripts for external libraries have been updated to use the HarmonyOS toolchain, but **they have not been fully tested**. If you enable libraries with `--enable-libopus`, `--enable-libx264`, etc., you may encounter compilation errors. Please test them yourself and adjust configure/CMake flags as needed.

## Limitations

- Path spaces in `OHOS_NDK_HOME` are supported at the shell-script level, but placing the project directory itself under a path with spaces may still cause issues in upstream Makefiles.

## Thanks to

- [ffmpeg-android-maker](https://github.com/Javernaut/ffmpeg-android-maker) — the original Android cross-compilation project this was based on.
- [jishuzhan.net/article/2005866386942902274](https://jishuzhan.net/article/2005866386942902274)

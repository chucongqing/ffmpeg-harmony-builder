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

## Limitations

- **External libraries are not yet supported**. Flags like `--enable-libopus` or `--enable-libx264` will not work because the dependency build scripts still reference the Android NDK toolchain.
- Path spaces in `OHOS_NDK_HOME` are supported at the shell-script level, but placing the project directory itself under a path with spaces may still cause issues in upstream Makefiles.

## Thanks to

- [ffmpeg-android-maker](https://github.com/Javernaut/ffmpeg-android-maker) — the original Android cross-compilation project this was based on.
- [jishuzhan.net/article/2005866386942902274](https://jishuzhan.net/article/2005866386942902274)

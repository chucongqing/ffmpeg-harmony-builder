# ffmpeg-harmony-builder

## Project Overview

This is a shell-script-based build system for cross-compiling FFmpeg and its third-party dependencies. It is intended to target **HarmonyOS (OpenHarmony)**, but the codebase is currently in a **transitional/mixed state** inherited from its Android-based predecessor.

The project was bootstrapped from [`ffmpeg-android-maker`](https://github.com/Javernaut/ffmpeg-android-maker) (see `README.md` for attribution). It has a single Git commit (`init`) and retains many Android-specific variable names and toolchain references throughout the library build scripts.

### Key Files

- **`ffmpeg-harmony-builder.sh`** — Main orchestration script. Sets up directories, parses CLI arguments, downloads sources, triggers per-library builds, checks for text relocations, and copies artifacts to `output/`.
- **`scripts/common-functions.sh`** — Shared utilities, notably `downloadTarArchive()` for fetching and extracting source tarballs.
- **`scripts/parse-arguments.sh`** — Parses command-line flags (target ABIs, API level, optional libraries, FFmpeg source type/version).
- **`scripts/export-host-variables.sh`** — Detects the host OS and exports build-tool paths (`cmake`, `make`, `ninja`, `meson`, `nasm`, `pkg-config`).
- **`scripts/export-build-variables.sh`** — Exports cross-compilation variables for the current target ABI (compiler, binutils, sysroot, install prefix, etc.).
- **`scripts/check-host-machine.sh`** — Validates that `OHOS_SDK_HOME` and `OHOS_NDK_HOME` environment variables are set.
- **`scripts/ffmpeg/build.sh`** — **Standalone HarmonyOS build script** (hardcoded for `aarch64-linux-ohos`). It does **not** participate in the main orchestration loop and directly invokes FFmpeg's `configure` with an OHOS SDK path. It also creates an HNP package.
- **`scripts/ffmpeg/build.sh.old`** — The original Android-compatible FFmpeg build script that **does** integrate with the orchestrator.

## Technology Stack

- **Language**: Bash / POSIX shell scripts
- **Build systems invoked**: Autotools (`configure` + `make`), CMake, Meson + Ninja
- **Target platform**: HarmonyOS (intended), but many scripts still reference the Android NDK toolchain
- **No package manager**: There is no `package.json`, `Cargo.toml`, `pyproject.toml`, or similar

## Directory Layout

```
.
├── ffmpeg-harmony-builder.sh   # Entry point
├── README.md
├── .gitignore
├── scripts/
│   ├── check-host-machine.sh
│   ├── common-functions.sh
│   ├── export-build-variables.sh
│   ├── export-host-variables.sh
│   ├── parse-arguments.sh
│   ├── ffmpeg/
│   │   ├── build.sh            # HarmonyOS-only standalone script
│   │   ├── build.sh.old        # Android-style orchestrated script
│   │   └── download.sh
│   └── <library>/
│       ├── build.sh
│       └── download.sh
```

Generated at runtime (ignored by `.gitignore`):
- `sources/` — Downloaded upstream source tarballs / git clones
- `build/` — Intermediate build artifacts
- `output/` — Final `.so` files and headers copied per ABI
- `stats/` — Build statistics (currently text-relocation checks)

## Supported External Libraries

The orchestrator can optionally build and link the following libraries into FFmpeg.

**Free libraries**
- `libaom` — AV1 encoder/decoder
- `libdav1d` — AV1 decoder
- `libmp3lame` — MP3 encoder
- `libopus` — Opus codec
- `libtwolame` — MP2 encoder
- `libspeex` — Speex codec
- `libvpx` — VP8/VP9 codec
- `libwebp` — WebP image format
- `libfreetype` — Font rendering
- `libfribidi` — Bidirectional text
- `mbedtls` — TLS/SSL (enables `https` protocol in FFmpeg)
- `libbluray` — Blu-ray playback
- `libxml2` — XML parsing

**GPL libraries** (requires `--enable-gpl` in FFmpeg)
- `libx264` — H.264 encoder
- `libx265` — H.265/HEVC encoder

## Build Commands

### Main orchestrator (Android-oriented legacy flow)

```bash
export OHOS_SDK_HOME=/path/to/ohos-sdk
export OHOS_NDK_HOME=/path/to/ohos-ndk
./ffmpeg-harmony-builder.sh [options]
```

Common options (parsed in `scripts/parse-arguments.sh`):
- `--target-abis=<abi1,abi2>` — Target ABIs: `x86`, `x86_64`, `armeabi-v7a`, `arm64-v8a` (default: all)
- `--android-api-level=<N>` — API level to compile against (default: 21)
- `--source-tar=<version>` — FFmpeg tarball version (default: 8.1)
- `--source-git-tag=<tag>` or `--source-git-branch=<branch>` — Use FFmpeg Git instead of tarball
- `--enable-<lib>` or `-<shortname>` — Enable a specific external library (see `parse-arguments.sh` for exact flags)
- `--enable-all-free` / `--enable-all-gpl` — Enable all free or all GPL libraries

Example:
```bash
./ffmpeg-harmony-builder.sh --target-abis=arm64-v8a --enable-libopus --enable-libx264
```

### Standalone HarmonyOS FFmpeg build

The file `scripts/ffmpeg/build.sh` is **not** invoked by the main loop. It is a standalone script that:
1. Hardcodes `OHOS_SDK=/root/ohos-sdk/linux`
2. Builds only for `aarch64-linux-ohos`
3. Packages the result as a HarmonyOS HNP (`.hnp`) via `hnpcli`

To use it, you must edit the hardcoded paths inside the script and run it directly from the FFmpeg source directory:

```bash
cd sources/ffmpeg-<version>
../../scripts/ffmpeg/build.sh
```

> **Agent Note**: If you are asked to fix or extend HarmonyOS support, be aware that the main orchestrator and most `scripts/<lib>/build.sh` files still use `ANDROID_NDK_HOME`, `ANDROID_ABI`, and the Android CMake toolchain. A proper HarmonyOS port will require updating `export-build-variables.sh` and each library build script to use the OHOS LLVM toolchain and `*-linux-ohos` target triples.

## Code Style Guidelines

- **Shebang**: Use `#!/usr/bin/env bash` for all scripts.
- **Indentation**: 2 spaces (no tabs).
- **Variable references**: Prefer `${VAR}` over `$VAR` for clarity.
- **Naming conventions**:
  - `FAM_` prefix for cross-compilation tool paths (e.g., `FAM_CC`, `FAM_AR`)
  - `ANDROID_` prefix for ABI/platform variables (legacy from the Android origin)
  - `OHOS_` prefix for HarmonyOS SDK paths (only in `check-host-machine.sh` and `scripts/ffmpeg/build.sh`)
- **Error handling**: Build scripts typically end with `|| exit 1` after `./configure`.
- **Comments**: Written in English throughout the orchestrator and common scripts; `scripts/ffmpeg/build.sh` contains Chinese comments.

## Testing & Quality Checks

There is **no automated test suite**.

The orchestrator does perform one runtime quality check:
- **`checkTextRelocations()`** (in `ffmpeg-harmony-builder.sh`): After each ABI build, it runs `readelf --dynamic` on all produced `.so` files and greps for `TEXTREL`. If any text relocations are found, the build aborts. This is critical because text relocations are forbidden on modern Android/HarmonyOS targets.

## Known Issues & Limitations

1. **Mixed Android/HarmonyOS terminology**: Most library build scripts reference `ANDROID_NDK_HOME` and Android CMake toolchain files. The main orchestrator expects `OHOS_SDK_HOME` / `OHOS_NDK_HOME` but then proceeds to use Android-style variables in `export-build-variables.sh`.
2. **Hardcoded paths in `scripts/ffmpeg/build.sh`**: The OHOS SDK path is hardcoded to `/root/ohos-sdk/linux`, and the target is hardcoded to `aarch64-linux-ohos`.
3. **`scripts/ffmpeg/build.sh` is decoupled**: It does not use the common variable-export mechanism and will not work with the `--enable-*` flags from the orchestrator.
4. **No `hnp.json` present**: The standalone `build.sh` tries to copy `hnp.json` into the install directory, but this file does not exist in the repository root.
5. **Single git commit**: The project is very new and has minimal history.

## Security Considerations

- The build scripts download source tarballs over HTTPS from upstream project sites (ffmpeg.org, googlesource.com, videolan.org, etc.).
- No checksum verification is performed after download.
- GPL libraries (`libx264`, `libx265`) require `--enable-gpl`, which the parser sets automatically when those libraries are requested.
- The standalone `scripts/ffmpeg/build.sh` enables both `--enable-gpl` and `--enable-nonfree` unconditionally.

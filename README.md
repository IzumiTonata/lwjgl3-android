# lwjgl3-android

Build system for compiling [LWJGL 3.3.1](https://github.com/LWJGL/lwjgl3) native libraries targeting Android (arm64-v8a, armeabi-v7a, x86_64).

Tested with Minecraft 1.19.3. Used by [Nebulae](https://github.com/IzumiTonata/Nebulae).

## Output

| Library                | Description             |
| ---------------------- | ----------------------- |
| `liblwjgl.so`          | LWJGL core              |
| `liblwjgl_opengl.so`   | OpenGL bindings         |
| `liblwjgl_stb.so`      | STB (image, font, etc.) |
| `liblwjgl_tinyfd.so`   | TinyFileDialogs         |
| `liblwjgl_freetype.so` | FreeType 2.13.3         |

## Requirements

- Linux x86_64
- Android NDK r23 or later
- CMake 3.22+
- Ninja
- autoconf, automake, libtool (for libffi)

```bash
sudo apt install cmake ninja-build autoconf automake libtool wget
```

## Build

```bash
git clone --recurse-submodules https://github.com/IzumiTonata/lwjgl3-android.git
cd lwjgl3-android

# Apply Android patches to LWJGL source
cd lwjgl3 && git apply ../lwjgl3-libffi-android.patch && cd ..

export ANDROID_NDK=/path/to/android-ndk
./build.sh
```

Output `.so` files will be in `dist/<ABI>/`.

## Patches

`lwjgl3-libffi-android.patch` fixes `org_lwjgl_system_libffi_LibFFI.c` to compile on Android:

- x86/Windows-only FFI calling convention constants (`FFI_WIN64`, `FFI_STDCALL`, etc.) are not defined on aarch64. The patch wraps them with `#ifdef` guards that fall back to returning `0`, so the JNI methods still exist and satisfy LWJGL's class initializer.

## Notes

- LWJGL source is pinned to tag `3.3.1` to match the jars bundled with Minecraft 1.19.3.
- `stubs/` contains `libglfw.so` stub libraries used as link-time dependencies for `liblwjgl_opengl.so`.
- liburing and platform-specific files (Windows, macOS, FreeBSD, UIO) are excluded from the build.

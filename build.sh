#!/bin/bash
set -e

NDK=${ANDROID_NDK:?"Please export $ANDROID_NDK=/path/to/your/ndk"}
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
ROOT=$(pwd)
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64")
API=24
LIBFFI_VER=3.4.6

if [ ! -d "libffi-${LIBFFI_VER}" ]; then
	wget "https://github.com/libffi/libffi/releases/download/v${LIBFFI_VER}/libffi-${LIBFFI_VER}.tar.gz"
	tar xf "libffi-${LIBFFI_VER}.tar.gz"
fi

build_libffi() {
	local ABI=$1
	local HOST CC
	case $ABI in
	arm64-v8a) HOST="aarch64-linux-android" ;;
	armeabi-v7a) HOST="armv7a-linux-androideabi" ;;
	x86_64) HOST="x86_64-linux-android" ;;
	esac
	CC="$TOOLCHAIN/bin/${HOST}${API}-clang"
	mkdir -p "$ROOT/libffi-build/$ABI"
	pushd "$ROOT/libffi-build/$ABI" >/dev/null
	"$ROOT/libffi-${LIBFFI_VER}/configure" \
		--host=$HOST \
		--disable-shared \
		--enable-static \
		--with-sysroot="$TOOLCHAIN/sysroot" \
		CC="$CC" \
		AR="$TOOLCHAIN/bin/llvm-ar" \
		RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
	make -j$(nproc)
	popd >/dev/null
}

for ABI in "${ABIS[@]}"; do
	echo "=== libffi: $ABI ==="
	build_libffi "$ABI"
done

for ABI in "${ABIS[@]}"; do
	echo "=== LWJGL: $ABI ==="
	cmake -B "$ROOT/build/$ABI" \
		-DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
		-DANDROID_ABI="$ABI" \
		-DANDROID_PLATFORM="android-$API" \
		-DANDROID_STL=none \
		-DLIBFFI_BUILD_DIR="$ROOT/libffi-build/$ABI" \
		-DCMAKE_BUILD_TYPE=Release \
		-G Ninja
	cmake --build "$ROOT/build/$ABI" --parallel
done

for ABI in "${ABIS[@]}"; do
	mkdir -p "$ROOT/dist/$ABI"
	find "$ROOT/build/$ABI" -name "liblwjgl*.so" -exec cp {} "$ROOT/dist/$ABI/" \;
	echo "dist/$ABI/: $(ls $ROOT/dist/$ABI/)"
done

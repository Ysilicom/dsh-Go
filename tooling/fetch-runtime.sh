#!/usr/bin/env bash
# Fetches prebuilt arm64-v8a runtime assets from official release to avoid building rootfs from scratch.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TARGET_DIR="$ROOT/runtime/out/arm64-v8a"
mkdir -p "$TARGET_DIR/assets/runtime"
mkdir -p "$TARGET_DIR/jniLibs/arm64-v8a"

APK_URL="${1:-https://github.com/ccch1mneyyy/dsh-Go/releases/download/v1.0.7/dsh-go-1.0.7-arm64.apk}"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[fetch-runtime] Downloading prebuilt runtime from: $APK_URL"
curl -fL --retry 3 -o "$TMP_DIR/official.apk" "$APK_URL"

echo "[fetch-runtime] Extracting assets/runtime..."
unzip -q -o "$TMP_DIR/official.apk" "assets/runtime/*" -d "$TMP_DIR/extracted"
cp -r "$TMP_DIR/extracted/assets/runtime"/* "$TARGET_DIR/assets/runtime/"

echo "[fetch-runtime] Extracting native binaries..."
unzip -q -o "$TMP_DIR/official.apk" "lib/arm64-v8a/libproot.so" "lib/arm64-v8a/libproot-loader.so" "lib/arm64-v8a/libtalloc.so" "lib/arm64-v8a/libandroid-shmem.so" -d "$TMP_DIR/extracted"
cp "$TMP_DIR/extracted/lib/arm64-v8a/"*.so "$TARGET_DIR/jniLibs/arm64-v8a/"

echo "[fetch-runtime] Runtime assets prepared successfully at: $TARGET_DIR"

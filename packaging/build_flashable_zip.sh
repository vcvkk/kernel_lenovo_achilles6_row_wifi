#!/bin/bash
# Packages an AnyKernel3-style TWRP-flashable zip from a built Image.gz-dtb.
#
# Usage: packaging/build_flashable_zip.sh <path-to-Image.gz-dtb> <output-zip-path>
set -euo pipefail

KERNEL_IMAGE="$1"
OUT_ZIP="$2"

if [ ! -f "$KERNEL_IMAGE" ]; then
	echo "error: kernel image not found: $KERNEL_IMAGE" >&2
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cp -r "$SCRIPT_DIR/anykernel/." "$WORKDIR/"
cp "$KERNEL_IMAGE" "$WORKDIR/Image.gz-dtb"

mkdir -p "$(dirname "$OUT_ZIP")"
rm -f "$OUT_ZIP"

(
	cd "$WORKDIR"
	zip -r9 "$OUT_ZIP" . -x ".git*"
)

echo "Flashable zip written to: $OUT_ZIP"

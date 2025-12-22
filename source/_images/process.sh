#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="original"
DST_DIR="processed"
MAX_WIDTH=1600
QUALITY=80

# Default: skip existing files
PROCESS_ALL=false

# Check for --all or -a
for arg in "$@"; do
    if [[ "$arg" == "--all" || "$arg" == "-a" ]]; then
        PROCESS_ALL=true
    fi
done

# ---------- 1) Convert JPG/JPEG → WebP ----------
find "$SRC_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) ! -name ".*" | while read -r src_file; do
    rel_path="${src_file#$SRC_DIR/}"
    dst_file="$DST_DIR/${rel_path%.*}.webp"

    if [[ "$PROCESS_ALL" == false && -f "$dst_file" ]]; then
        continue
    fi

    mkdir -p "$(dirname "$dst_file")"
    echo "Converting JPG/JPEG: $src_file -> $dst_file"
    cwebp -q "$QUALITY" -resize "$MAX_WIDTH" 0 "$src_file" -o "$dst_file"
done

# ---------- 2) Copy all non-JPG/JPEG files ----------
find "$SRC_DIR" -type f ! \( -iname "*.jpg" -o -iname "*.jpeg" \) ! -name ".*" | while read -r src_file; do
    rel_path="${src_file#$SRC_DIR/}"
    dst_file="$DST_DIR/$rel_path"

    if [[ "$PROCESS_ALL" == false && -f "$dst_file" ]]; then
        continue
    fi

    mkdir -p "$(dirname "$dst_file")"
    echo "Copying file: $src_file -> $dst_file"
    cp "$src_file" "$dst_file"
done


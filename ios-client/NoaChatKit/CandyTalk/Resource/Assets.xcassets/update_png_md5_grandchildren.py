#!/usr/bin/env python3
"""
Batch update PNG file MD5 values in grandchildren directories only.

Scope:
- Current directory: .
- Child directories: ./<child>/
- Grandchild directories: ./<child>/<grandchild>/
- Process only PNG files inside grandchild directories.
"""

from __future__ import annotations

import os
import random
import struct
import time
import zlib
from pathlib import Path

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def _is_valid_png(data: bytes) -> bool:
    return len(data) >= 8 and data.startswith(PNG_SIGNATURE)


def _chunk(chunk_type: bytes, chunk_data: bytes) -> bytes:
    length = struct.pack(">I", len(chunk_data))
    crc = zlib.crc32(chunk_type + chunk_data) & 0xFFFFFFFF
    return length + chunk_type + chunk_data + struct.pack(">I", crc)


def _inject_text_chunk(original: bytes, key: str, value: str) -> bytes:
    """
    Insert a tEXt chunk before IEND to change file bytes while keeping PNG valid.
    """
    if not _is_valid_png(original):
        raise ValueError("Not a valid PNG signature.")

    text_data = key.encode("latin-1", errors="strict") + b"\x00" + value.encode(
        "latin-1", errors="strict"
    )
    text_chunk = _chunk(b"tEXt", text_data)

    pos = 8
    end = len(original)
    while pos + 12 <= end:
        chunk_len = struct.unpack(">I", original[pos : pos + 4])[0]
        chunk_type = original[pos + 4 : pos + 8]
        chunk_total = 12 + chunk_len
        if pos + chunk_total > end:
            raise ValueError("Corrupted PNG chunk length.")
        if chunk_type == b"IEND":
            return original[:pos] + text_chunk + original[pos:]
        pos += chunk_total

    raise ValueError("IEND chunk not found.")


def _update_one_png(path: Path) -> bool:
    """
    Return True if updated; raise exception on failure.
    """
    data = path.read_bytes()
    nonce = f"{int(time.time())}-{random.getrandbits(64):016x}"
    new_data = _inject_text_chunk(data, "md5_nonce", nonce)
    path.write_bytes(new_data)
    return True


def iter_grandchild_pngs(root: Path):
    """
    Yield png files from ./<child>/<grandchild>/*.png only.
    """
    for child in root.iterdir():
        if not child.is_dir():
            continue
        for grandchild in child.iterdir():
            if not grandchild.is_dir():
                continue
            for item in grandchild.iterdir():
                if not item.is_file():
                    continue
                if item.suffix.lower() != ".png":
                    # Skip non-PNG files by requirement
                    continue
                yield item


def main() -> int:
    root = Path.cwd()
    total_png = 0
    modified = 0
    failed = 0

    for png in iter_grandchild_pngs(root):
        total_png += 1
        try:
            _update_one_png(png)
            modified += 1
            print(f"[OK] {png}")
        except Exception as exc:
            failed += 1
            print(f"[SKIP] {png} ({exc})")

    print("\nDone.")
    print(f"Total PNG found: {total_png}")
    print(f"Modified: {modified}")
    print(f"Skipped (failed/unmodifiable): {failed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

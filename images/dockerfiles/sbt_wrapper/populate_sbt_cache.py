#!/usr/bin/env python3

import os
import shutil


def get_file_paths_under(root=".", *, suffix=""):
    """Generates the paths to every file under ``root``."""
    if not os.path.isdir(root):
        raise ValueError(f"Cannot find files under non-existent directory: {root!r}")

    for dirpath, _, filenames in os.walk(root):
        for f in filenames:
            if os.path.isfile(os.path.join(dirpath, f)) and f.lower().endswith(suffix):
                yield os.path.join(dirpath, f)


def homedir(name):
    return os.path.join(os.environ["HOME"], name)


def sync_dir(src, dst):
    for src_f in get_file_paths_under(src):
        dst_f = os.path.join(dst, os.path.relpath(src_f, src))
        if not os.path.exists(dst_f):
            os.makedirs(os.path.dirname(dst_f), exist_ok=True)
            shutil.move(src_f, dst_f)


if __name__ == "__main__":
    sync_dir(src=homedir(".sbt.image"), dst=homedir(".sbt"))
    sync_dir(src=homedir(".ivy2.image"), dst=homedir(".ivy2"))

# Small script to rename the directories containing NEH and other images
# to conform with the conventions used to name the directories containing
# the JTS images (from Ben Johnston).
#
# The filenames remain unchanged; the directory names are left-padded
# with zeros to a uniform 6 characters.

import os
from pathlib import Path
from contextlib import contextmanager
import argparse


@contextmanager
def pushd(new_dir):
    previous_dir = os.getcwd()
    os.chdir(new_dir)
    try:
        yield
    finally:
        os.chdir(previous_dir)

parser = argparse.ArgumentParser(description="pad names of subdirectories to 6 characters")
parser.add_argument('Path',
                    metavar='path',
                    type=str,
                    help='the directory to modify')

args = parser.parse_args()

root_dir = args.Path

if not os.path.isdir(root_dir):
    print(f"{root_dir} is not a directory")
    sys.exit()


with pushd(root_dir) as top:
    for root, dirs, files in os.walk(os.getcwd(), topdown=False):
            old_path = Path(root)
            new_path = old_path.parent / Path(old_path.name.zfill(6))
            old_path.rename(new_path)

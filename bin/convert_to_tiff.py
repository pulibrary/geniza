'''
Created on November 30, 2021
@author: cwulfman
'''

import os
import argparse


def convert_images(sourcedir, targetdir):
    '''Convert jp2 files to tif files.'''

    for root, dirs, files in os.walk(sourcedir):
        for fname in files:
            if fname.endswith('.jp2'):
                cmd = 'kdu_expand -i ' + root + '/' + fname
                cmd += ' -o ' + root + '/' + fname.replace('.jp2', '.tif')
                os.system(cmd)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_dir",
                        help="top-level directory of source tifs.")
    parser.add_argument("-o", "--output_dir", help="target directory.")
    args = parser.parse_args()

    if args.input_dir and args.output_dir:
        convert_images(args.input_dir, args.output_dir)



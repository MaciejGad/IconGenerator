#!/bin/bash

mkdir -p all_colors

for x in `cat colors.txt`; do
    echo "Generating icon for $x"
    ./icon_gen.swift f040 $x --output all_colors/$x.png
done
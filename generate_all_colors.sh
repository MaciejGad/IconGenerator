#!/bin/bash

make -s

mkdir -p all_colors

for x in `cat colors.txt`; do
    echo "Generating icon for $x"
    ./icon_gen f040 $x --output all_colors/$x.png
done

for x in `cat colors.txt`; do
    echo "Generating reverse icon for $x "
    ./icon_gen f040 $x --output all_colors/reversed_$x.png --reversed
done
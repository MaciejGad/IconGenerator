#!/bin/bash

make -s

mkdir -p FontAwesomeIconsNoGrandient

for code in `cat font_awesome_icons.txt`; do
    echo "Generating icon for $code"
    ./icon_gen $code --output FontAwesomeIconsNoGrandient/$code.png --no-gradient
done

# mkdir -p tablerIcons

# for code in `cat tabler_icons_icons.txt`; do
#     echo "Generating icon for $code"
#     ./icon_gen $code --font-name tabler-icons --output tablerIcons/$code.png
# done
#!/usr/bin/python3

from fontTools.ttLib import TTFont
import sys

def list_supported_chars(font_path):
    font = TTFont(font_path)
    cmap = font['cmap'].tables  #
    supported_chars = set()
    for table in cmap:
        if table.isUnicode():
            supported_chars.update(table.cmap.keys())  
    hex_list = [hex(c) for c in sorted(supported_chars)]
    return hex_list

if len(sys.argv) != 2:
    print("Usage: python list_supported.py <font_path>")
    sys.exit(1)

font_path = sys.argv[1]
l =  list_supported_chars(font_path)
print(len(l))
with open("supported_chars.txt", "w") as f:
    for char in l:
        f.write(f"{char[2:]}\n")
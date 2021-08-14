#!/bin/bash

shopt -s globstar
cd HPMOR_data/Iteration2/paragraph_images/ || { echo "Cannot find folder: HPMOR_data/paragraph_images/!"; exit 1; }

for f in **/*.png; do
    base64 "$f" > "${f:0:${#f}-4}_b64.txt"
done

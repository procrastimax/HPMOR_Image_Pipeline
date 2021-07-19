# HPMOR Image Pipeline
With the help of this repo one can easily create images from text paragraphs from the HPMOR fan fiction.
All images are saved in the `HPMOR_data` folder. Also the original text and context images are saved there for each paragraph.

## Installation
Just execute the *installer.bash* with `bash installer.bash` to download all needed repos and setting up the folder structure.

Needed programs are:

- `bash`
- `python3`
- `pip3`
- `virtualenv` (can be installed with `pip3 install virtualenv`)

## Image creation
The paragraph images can be created by executing `bash text_image_creator.bash`.
With the `-h` flag all possible options to this script are displayed.

## Base64 creation
When executing the `create_base64_files.bash` script, all *.png* files inside the HPMOR_data/paragraph_images/ are encoded as base64 and saved as text files.

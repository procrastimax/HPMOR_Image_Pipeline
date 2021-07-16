#!/bin/sh

echo "Downloading needed repos..."
echo "TextChunkGenerator:"
git clone https://github.com/procrastimax/TextChunkGenerator.git

echo "HPMOR_crawler:"
git clone https://github.com/procrastimax/HPMOR_crawler.git

echo "TextToImageConvert:"
git clone https://github.com/procrastimax/TextToImage.git

echo "Creating data folder..."
mkdir -v -p HPMOR_data/paragraph_images/

echo "Creating python virtual env. 'virtualenv' is needed!"
python3 -m virtualenv env

echo "Activating venv..."
source ./env/bin/activate

echo "Installing all requirements ('pip3' needed!)..."
find . -name requirements.txt -print0 | xargs -0 -I {} pip3 install -r {}

echo "Installing nltk..."
python3 -m nltk.downloader punkt -d .

deactivate

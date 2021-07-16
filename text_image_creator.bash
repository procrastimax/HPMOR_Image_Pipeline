#!/bin/bash

CHAPTER_NR=-1
CH_FILENAME=""
CHUNK_LENGTH=100

# the number of characters in each generated image from text
IMAGE_TEXT_WIDTH=100
MARGIN=12
FONT_SIZE=12

NUMBER_OF_CONTEXT_SENTENCES=2
CONTEXT_FG="#333333"
CONTEXT_BG="#bcbcbc"

USAGE="Usage: [-h] -c CHAPTER_NR -f FILENAME [-a] CONTEXT_FG_COLOR [-b] CONTEXT_BG_COLOR [-m] MARGIN [-s] FONT_SIZE [-w] IMAGE_TEXT_WIDTH [-d] CHUNK_LENGTH [-l] NUMBER_OF_CONTEXT_SENTENCES
    -h              Shows this help text.
    -c CHAPTER_NR   Specifies the chapter number to be crawled.
                    It is saved as a chunked version to file with name: 'chunked_ch_NR.txt'
    -f FILENAME     If '-c' is not specified, this specifies the previously downloaded and chunked filename.
    -a COLOR        Hex color string to specify the default foreground color of the generated context images.
                    Default: #333333
    -b COLOR        Hex color string to specify the default background color of the generated context images.
                    Default: #bcbcbc
    -m MARGIN       Margin in px between text and frame of text images.
                    Default: 24
    -s FONT_SIZE    Fonsize of all generated text images.
                    Default 12
    -w WIDTH        Width of all text images measured by number of characters in each line.
                    Default: 100
    -d LENGTH       Length of generated text chunks measured by number of words.
                    Default: 100
    -l NUMBER       Number of context sentences used to generate context images.
                    Default: 2"

if [[ $# -lt 1 ]]; then
    echo "Please specify some arguments!"
    echo "$USAGE"
    exit 1
fi

while getopts ":hc:f:a:b:m:s:w:d:l:" opt; do
	case ${opt} in
		h ) echo "$USAGE"
                    exit 1
                    ;;
		\? ) echo "$USAGE"
                    exit 1
                    ;;
		c ) CHAPTER_NR="$OPTARG"
		    ;;
		f ) if [[ "$CHAPTER_NR" -ne -1 ]]; then
                        echo "Cannot specify chapter number to crawl AND pre-crawled/ pre-chunked textfile!"
                    else
                        CH_FILENAME="$OPTARG"
                    fi
	            ;;
                a ) CONTEXT_FG="$OPTARG"
                    ;;
                b ) CONTEXT_BG="$OPTARG"
                    ;;
                m ) MARGIN="$OPTARG"
                    ;;
                s ) FONT_SIZE="$OPTARG"
                    ;;
                w ) IMAGE_TEXT_WIDTH="$OPTARG"
                    ;;
                d ) CHUNK_LENGTH="$OPTARG"
                    ;;
                l ) NUMBER_OF_CONTEXT_SENTENCES="$OPTARG"
                    ;;
                : ) echo "Invalid option: '-$OPTARG' requires an argument" 1>&2
                    echo "$USAGE"
                    exit 1
	esac
done
shift $((OPTIND -1))

# activating pyenv
source ./env/bin/activate

if [[ $CHAPTER_NR -gt 0 ]]; then
    CH_FILENAME="chapter_ch_$CHAPTER_NR.txt"
    # Download specified chapter and save as .txt file
    python3 HPMOR_crawler/main.py -s "$CHAPTER_NR" -e "$CHAPTER_NR" -t
    # chunk downloaded text
    python3 TextChunkGenerator/main.py -f "crawled.txt" -i "$CHUNK_LENGTH" -o "$CH_FILENAME"
    # remove downloaded text
    rm crawled.txt
fi

rm -r HPMOR_data/paragraph_images/*

# split text into chunked text
echo "Splitting text for: $CH_FILENAME"
split -l 2 "$CH_FILENAME" par-

PREV_F=""

for F in par-*
do
    echo -ne "Handling: $F\r"

    # create context paragraph image for each paragraph
    python3 TextChunkGenerator/main.py -f "$F" -s "$NUMBER_OF_CONTEXT_SENTENCES" >> "pre_$F.txt"
    python3 TextChunkGenerator/main.py -f "$F" -s "$NUMBER_OF_CONTEXT_SENTENCES" -r >> "post_$F.txt"

    # remove empty lines and create images
    mkdir "HPMOR_data/paragraph_images/$F"
    awk 'NF' "$F" | python3 TextToImage/main.py -w "$IMAGE_TEXT_WIDTH" -s "$FONT_SIZE" -m "$MARGIN" -o "HPMOR_data/paragraph_images/$F/$F.png"

    awk 'NF' "$F" >> "HPMOR_data/paragraph_images/$F/$F.txt"

    # create context paragraphs
    if [ -n "$PREV_F" ]; then # check if PREV_F is not empty
        python3 TextToImage/main.py -i "post_$PREV_F.txt" -w "$IMAGE_TEXT_WIDTH" -s"$FONT_SIZE" -m "$MARGIN" -fg "$CONTEXT_FG" -bg "$CONTEXT_BG" -o "HPMOR_data/paragraph_images/$F/pre_$F.png"
        python3 TextToImage/main.py -i "pre_$F.txt" -w "$IMAGE_TEXT_WIDTH" -s "$FONT_SIZE" -m "$MARGIN" -fg "$CONTEXT_FG" -bg "$CONTEXT_BG" -o "HPMOR_data/paragraph_images/$PREV_F/post_$PREV_F.png"
        cp "post_$PREV_F.txt" "HPMOR_data/paragraph_images/$F/"
        cp "pre_$F.txt" "HPMOR_data/paragraph_images/$PREV_F/"
    fi

    PREV_F="$F"
done

# copy the chunked text into the data folder
cp "$CH_FILENAME" ./HPMOR_data/ -v

echo
echo "Cleaning up..."
rm ./*par-*

deactivate

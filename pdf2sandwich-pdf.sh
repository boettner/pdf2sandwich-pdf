#!/bin/bash

PDFFILE=$1
LANG=deu        # See man tesseract > LANGUAGES
MIN_WORDS=5     # Number of words required to accept pdftotext result.

if [[ -z "$PDFFILE" ]]; then
	echo "syntax: $(basename $0) <INPUT PDF>"
	exit 1
fi

# Check if pdf already has embedded text.
pdftotext "$PDFFILE" "/tmp/temp.txt"
FILESIZE=$(wc -w < "/tmp/temp.txt")
rm /tmp/temp.txt

# If that fails, try Tesseract.
if [[ $FILESIZE -lt $MIN_WORDS ]]
then
    echo -n "Attempting OCR extraction...\n"

    # backup original pdf file
    cp -a $PDFFILE $PDFFILE.bck

    # Use imagemagick to convert the PDF to a high-rest multi-page TIFF.
    convert -density 300 "$PDFFILE" -depth 8 -strip -background white -alpha off /tmp/temp.tiff

    # Then use Tesseract to perform OCR on the tiff.
    tesseract /tmp/temp.tiff "$(dirname $PDFFILE)/$(basename $PDFFILE .pdf)" -l $LANG pdf

    # We don't need then intermediate TIFF file, so discard it.
    rm /tmp/temp.tiff

    echo -n "PDF successfully sandwiched! \O/ \n"
else
    echo -n "pdftotext extracted $FILESIZE words. Skip OCR process.\n"
fi

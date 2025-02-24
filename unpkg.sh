#!/bin/sh
CWD=`pwd`
PKG_FILE=$1
PKG_FILENAME=`basename "$PKG_FILE" .pkg`
EXTRACTION_DIR="$CWD/$PKG_FILENAME"


check_input() {
    # Check if the filename is provided
    if [ $1 -ne 1 ]; then
        echo "Usage: $0 <pkg_file>"
        exit 1
    fi


    # Check if the file exists
    if [ ! -f "$PKG_FILE" ]; then
        echo "File not found: $PKG_FILE"
        exit 1
    fi
}


cleanup_extraction_dir() {
    
    echo "[*] Removing previous $EXTRACTION_DIR"
    rm -rf "$EXTRACTION_DIR"
    mkdir "$EXTRACTION_DIR"

}

extract_pkg() {
    
    APP_DIR=$1
    
    echo "[*] Extracting $APP_DIR"
    
    cd $APP_DIR

    # Extract preinstall and postinstall scripts if exist
    if [ -f Scripts ]; then
        gunzip -dc "Scripts" | cpio -i
    fi

    # Extract Payload
    gunzip -dc "Payload" | cpio -i
    
    cd ..
    
}


check_input $#
cleanup_extraction_dir

# Extract .pkg file
echo "[*] Unpack $PKG_FILE"
xar -C "$EXTRACTION_DIR" -xf "$PKG_FILE" || exit

cd "$EXTRACTION_DIR"

# Get the value of tag 'pkg-ref' and remove the first character (it seems to be '#')
APP_DIRS=`xmllint --xpath '//pkg-ref/text()' Distribution | cut -c2- | tr '[:space:]' '\n'`

while IFS= read -r line; do
    if [ ! -z "$line" ]; then
        extract_pkg "$line"
    fi
done <<< "$APP_DIRS"

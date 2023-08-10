#!/bin/sh

# Set trap immediately after the shebang
trap "rm -f /tmp/script_running" EXIT

echo "Script is running" > /tmp/script_running

EBOOKS_DIR="/ebooks"           # Mount point for eBooks in the container
AUDIOBOOKS_DIR="/audiobooks"   # Mount point for audiobooks in the container

send_notification() {
    DIRECTORY=$1
    TOKEN=$2
    FILE=$3

    curl -s \
         --form-string "token=$TOKEN" \
         --form-string "user=$PUSHOVER_USER_TOKEN" \
         --form-string "message=New file added: $FILE" \
         https://api.pushover.net/1/messages.json
}

monitor_directory() {
    DIRECTORY=$1
    TOKEN=$2
    FILETYPES=$3

    inotifywait -m -e create -r --format '%w%f' "$DIRECTORY" | while read FILE
    do
        for FILETYPE in $FILETYPES; do
            if [[ "$FILE" == *.$FILETYPE ]]; then
                send_notification "$DIRECTORY" "$TOKEN" "$FILE"
                break
            fi
        done
    done
}

# File extensions to monitor
EBOOK_EXTENSIONS="epub"
AUDIOBOOK_EXTENSIONS="mp3 m4b m4a"

# Start monitoring
monitor_directory "$EBOOKS_DIR" "$PUSHOVER_EBOOKS_TOKEN" "$EBOOK_EXTENSIONS" &
monitor_directory "$AUDIOBOOKS_DIR" "$PUSHOVER_AUDIOBOOKS_TOKEN" "$AUDIOBOOK_EXTENSIONS" &
wait

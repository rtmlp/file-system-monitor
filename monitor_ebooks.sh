#!/bin/sh

EBOOKS_DIR="/ebooks"  # Adjust if necessary, but this will be our mount point in the container

inotifywait -m -e create -r --format '%w%f' "$EBOOKS_DIR" | while read FILE
do
    if [[ "$FILE" == *.epub ]]; then
        curl -s \
             --form-string "token=YOUR_APP_TOKEN" \
             --form-string "user=YOUR_USER_KEY" \
             --form-string "message=New ebook added: $FILE" \
             https://api.pushover.net/1/messages.json
    fi
done

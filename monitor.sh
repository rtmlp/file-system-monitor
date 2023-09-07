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

    # Send the notification
    CURL_OUTPUT=$(curl -s -o /dev/null -w "%{http_code}" \
                       --form-string "token=$TOKEN" \
                       --form-string "user=$PUSHOVER_USER_TOKEN" \
                       --form-string "message=New file added: $FILE" \
                       https://api.pushover.net/1/messages.json)

    # Check for success (HTTP status code in the range 200-299)
    if [ $CURL_OUTPUT -ge 200 ] && [ $CURL_OUTPUT -le 299 ]; then
        echo "Notification successfully sent for file: $FILE"
    else
        # Log the HTTP status code if an error occurred
        echo "Error sending notification, HTTP Status Code: $CURL_OUTPUT"

        # Send an error notification
        curl -s \
             --form-string "token=$TOKEN" \
             --form-string "user=$PUSHOVER_USER_TOKEN" \
             --form-string "message=Error sending notification for file: $FILE" \
             https://api.pushover.net/1/messages.json
    fi
}

monitor_directory() {
    DIRECTORY=$1
    TOKEN=$2
    FILETYPES=$3

    inotifywait -m -e create,moved_to,close_write -r --format '%w%f' "$DIRECTORY" | while read FILE
    do
        echo "Detected file event: $FILE"
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

# Wait for all background jobs to finish
wait

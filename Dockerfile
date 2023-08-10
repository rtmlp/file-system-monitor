# Use a lightweight base image
FROM alpine:latest

# Install inotify-tools and curl
RUN apk update && apk add inotify-tools curl

# Add our monitoring script
COPY monitor_ebooks.sh /usr/local/bin/

# Ensure the script is executable
RUN chmod +x /usr/local/bin/monitor_ebooks.sh

# Command to run the script
CMD ["monitor_ebooks.sh"]
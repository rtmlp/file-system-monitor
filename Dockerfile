# Use a lightweight base image
FROM alpine:latest

# Install inotify-tools, curl, and darkhttpd
RUN apk update && apk add inotify-tools curl darkhttpd

# Add our monitoring script
COPY monitor.sh /usr/local/bin/

# Ensure the script is executable
RUN chmod +x /usr/local/bin/monitor.sh

# Start the main script and the HTTP server
CMD ["sh", "-c", "/usr/local/bin/monitor.sh & darkhttpd /tmp --port 8080"]

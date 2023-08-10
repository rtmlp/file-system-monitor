# Use a lightweight base image
FROM alpine:latest

# Install inotify-tools and curl
RUN apk update && apk add inotify-tools curl busybox-extras

# Add our monitoring script
COPY monitor.sh /usr/local/bin/

# Ensure the script is executable
RUN chmod +x /usr/local/bin/monitor.sh

# Start the main script and the HTTP server
CMD ["sh", "-c", "/usr/local/bin/monitor.sh & busybox httpd -f -p 8080 -h /tmp"]
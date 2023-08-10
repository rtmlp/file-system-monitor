# file-system-monitor
Monitor the file systems for ebooks and audiobooks using inotify-tools and send the notifications to pushover system. This container may not be used by anyone except myself.

# Setup
1. Create an Environment File

You can create a file named `monitor.env` and inside monitor.env, add:

```
PUSHOVER_USER_TOKEN=your_user_token
PUSHOVER_EBOOKS_TOKEN=your_ebooks_token
PUSHOVER_AUDIOBOOKS_TOKEN=your_audiobooks_token
```

2. Create a docker-compose file and reference the environment file 

```
version: '3'

services:
  file-system-monitor:
    image: ghcr.io/rtmlp/file-system-monitor:latest
    volumes:
      - /path/to/ebooks:/ebooks
      - /path/to/audiobooks:/audiobooks
    env_file:
      - /path/to/monitor.env
```

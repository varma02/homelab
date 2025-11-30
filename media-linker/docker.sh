#!/bin/bash

docker run --rm -it \
  -v /mnt/SigmaPool/jellyfin/media:/media \
  -v /mnt/SigmaPool/torrent/downloads:/downloads
  busybox
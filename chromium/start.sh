#!/bin/bash

echo "Starting virtual display..."

Xvfb :99 -screen 0 1280x720x24 &
export DISPLAY=:99

# give X server time
sleep 2

echo "Starting Chrome..."

google-chrome \
  --no-sandbox \
  --disable-gpu \
  --disable-dev-shm-usage \
  --autoplay-policy=no-user-gesture-required \
  --disable-background-timer-throttling \
  --disable-renderer-backgrounding \
  --disable-backgrounding-occluded-windows \
  --window-size=1280,720 \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222 \
  --user-data-dir=/data \
  "$@"

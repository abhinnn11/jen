docker compose down
docker rm -f jenkins 2>/dev/null
docker image prune -a -f
docker compose build --no-cache
docker compose up -d
